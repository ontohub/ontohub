#!/bin/ksh93

# Shell script to be executed by Jenkins in the 'Build' step for each PR
# webhook sent for the https://github.com/ontohub/ontohub/ repository. It
# allows concurrent builds and thus CI is just limited by the resources of
# the executing machine and Jenkins configuration.
#
# This script is green, because it avoids polling and does not need
# daily "cronjobs" for nightly builds thus unecessary/redundant builds: after a
# successful test run it checks, whether the PR got merged. If so and it is
# the youngest merge seen so far, the corresponding timestamp gets stored into
# ${BR_STATE_DIR}/${targetBranch}. At this place one may setup additional
# commands usually executed by successful nightly builds. See 
# updateBranchStateLocal() for more information.

# This script requires, that in the configuration for this job alias project
# the workspace directory has been explicitly set to (basename is important):
#           jobs/${JOB_NAME}/workspace_${EXECUTOR_NUMBER}
# Click above "Source Code Management" the <Advanced> button, enable
# "Use custom workspace" and set "Directory" to the value shown above.

# (C) 2016, Jens Elkner, Uni Magdeburg. All rights reserved.
# License: see ../LICENSE

[[ -r /local/usr/ruby/.profile ]] && . /local/usr/ruby/.profile

# some global vars to remember - don't wanna re-compute them in each function
[[ -z ${WORKSPACE} ]] && WORKSPACE=${PWD}
DATADIR=${WORKSPACE}/tmp/db # need to be absolute !
typeset PR_IDF="${WORKSPACE}/tmp/PULLID_${ghprbPullId}"
typeset BR_STATE_DIR=${JENKINS_HOME}/branch_states


typeset PGBIN=${ pg_config --bindir ; }
export PGDATA=${DATADIR}/pgsql/main PGHOST=${DATADIR}/var PGPORT=0
#	dueto ontohub design flaw, ontohub wanna play DBA
PG_DBA=postgres

RDATA=${DATADIR}/redis RPID=0 RPORT=0
#	for sidekiq
export RSOCK="unix://${RDATA}/redis.sock" REDIS_PROVIDER=RSOCK

EDATA=${DATADIR}/esearch EPORT=0

HPID=0

if [[ ${ uname -s ; } == 'SunOS' ]]; then
	typeset SED=gsed DATE=gdate
else
	typeset SED=sed DATE=date
fi

typeset -T LogObj_t=(
	# AnsiColor Plugin detects simple colors/"sequences", only.
    typeset -Sh 'Color for info messages' GREEN='36';
    typeset -Sh 'Color for warning messages' BLUE='34';
    typeset -Sh 'Color for fatal messages' RED='31';
    function log {
        print -u2 "\E[1m\E[$2m$3\E[0m"
    }
    typeset -Sfh ' log a message to stderr' log
    function info {
        _.log "INFO" ${_.GREEN} "$*"
    }
    typeset -Sfh ' log a info message to stderr' info
    function warn {
        _.log "WARN" ${_.BLUE} "$*"
    }
    typeset -Sfh ' log a warning message to stderr' warn
    function fatal {
        _.log "FATAL" ${_.RED} "$*"
    }
    typeset -Sfh ' log a fatal error message to stderr' fatal
    function printMarker {
        typeset COLOR="$1"
        print -f '\E[1;%sm----------------------------------------------------------------------------\E[0m\n' "${COLOR:-${_.GREEN}}"
    }
    typeset -Sfh ' print a marker line to stdout' printMarker
)
LogObj_t Log

function tearDown {
	${PGBIN}/pg_ctl -s -m fast stop
	(( RPID )) && kill -9 ${RPID}
	(( HPID )) && kill -9 ${HPID}
	[[ -s ${EDATA}/pid ]] && kill -9 $(<${EDATA}/pid)
	rm -f ${PR_IDF}
	return 0
}

function prepareDatabase {
	integer PORT=${EXECUTOR_NUMBER} C
	(( PGPORT=PORT*10 + 15000 ))
	(( C=PGPORT+10-1 ))
	Log.warn "Used port range: ${PGPORT}..$C"

	Log.info 'Setting up Postgres DB ...'
	rm -rf ${RDATA} ${PGHOST} ${PGDATA}
	mkdir -p ${RDATA} ${PGHOST} ${PGDATA} || exit 1

    if [[ ! -x ${PGBIN}/initdb ]]; then
		print -u2 "Uhmm '${PGBIN}/initdb' is not executable!"
		return 1
	fi
    
    ${PGBIN}/pg_ctl init -s -w -m fast \
		-o "-E UTF8 --locale=en_US.UTF-8 --username=${PG_DBA}"
	PROP='unix_socket_directories'
	${SED} -i -e "/^#${PROP}/ s,^.*,${PROP} = '${DATADIR}/var'," \
		-e "/^#port/ s,^.*,port = ${PGPORT}," \
		${PGDATA}/postgresql.conf

	${PGBIN}/pg_ctl -s -w start || return $?
	print -n 'create user ontohub;
create database ontohub OWNER=ontohub;
create database ontohub_test OWNER=ontohub;
create database ontohub_development OWNER=ontohub;
'	| psql -d postgres -U ${PG_DBA}

	# stupid rails does not honor PGPORT -> calculates the wrong socket path
	${SED} -r -i -e "/^  (# *)?port/ s,^.*,  port: ${PGPORT}," \
		${WORKSPACE}/config/database.yml

	Log.info 'Setting up Redis DB ...'
	(( RPORT=PGPORT + 1 ))
	cat >${RDATA}/redis.conf<<EOF
pidfile ${RDATA}/pid
port ${RPORT}
tcp-backlog 128
unixsocket ${RSOCK#unix://}
unixsocketperm 0777
logfile ${RDATA}/redis-server.log
databases 4
dir ${RDATA}
EOF
	/usr/bin/redis-server ${RDATA}/redis.conf >${RDATA}/server.out 2>&1 &
	RPID=$!
	kill -0 ${RPID}
}

function prepareEsearch {
	Log.info 'Setting up ElasticSearch ...'
	rm -rf ${EDATA}
	mkdir -p ${EDATA}/{conf,data,logs} || exit 1
	cp /etc/elasticsearch/logging.yml ${EDATA}/conf/logging.yml

	integer EPORT2
	(( EPORT=RPORT + 1 ))
	(( EPORT2=EPORT + 1 ))
	typeset ES_HOME=/usr/share/elasticsearch
	typeset -a OPTS=(
		-d -p ${EDATA}/pid
		--default.path.home=${ES_HOME}
		--default.path.logs=${EDATA}/logs
		--default.path.data=${EDATA}/data
		--default.path.conf=${EDATA}/conf
	)
	# this sucks - can't be specified via CLI/JAVA_OPTS
	cat >${EDATA}/conf/elasticsearch.yml<<EOF
http.port: ${EPORT}
transport.tcp.port: ${EPORT2}
EOF
	export ES_GC_LOG_FILE=${EDATA}/logs/gc.log
	# haben keine cluster, ergo brauchen wir den Port auch nicht konfigurieren
	${ES_HOME}/bin/elasticsearch "${OPTS[@]}"
}

function prepareHets {
	Log.info 'Setting up hets ...'
	integer HPORT
	(( HPORT=EPORT + 2 ))
	print "hets:\n  port: ${HPORT}\n  executable_path: /usr/bin/hets-server" \
		>${WORKSPACE}/config/settings.local.yml
	return 0

	/usr/bin/hets-server -X -A --casl-amalg=none -S ${HPORT} \
		>${DATADIR}/hets.out 2>&1 &
	HPID=$!
	kill -0 ${HPID}
}

function setupDirs {
	Log.info 'Setting up Ontohub data directories ...'
	rm -rf spec/fixtures/vcr/hets-out tmp/{git,data}
	mkdir -p tmp/{git,data/git}
	mkdir tmp/data/{git_daemon,commits}
}

function killSamePRbuilds {
	if [[ -z ${ghprbPullId} ]]; then
		Log.warn 'ghprbPullId env var is not set - concurrent builds for' \
			'same PR get not killed!'
		return 0
	fi
	typeset F SFX=${PR_IDF#*workspace_*/} S
	integer FPID
	print $$ >${PR_IDF}
	print ${BUILD_NUMBER} >${PR_IDF}.num
	# This relies on the contract, that all workspace basenames are named
	# "workspace_${EXECUTOR_NUMBER}" and have the same parent directory.
	cd ${WORKSPACE}/..
	for F in ~(N)workspace_[0-9]*/${SFX} ; do
		[[ -n $F && -s $F ]] || continue
		FPID=$(<$F)
		(( FPID == $$ || FPID == 0 )) && continue
		[[ -s ${F}.num ]] && S=$(<${F}.num) || S='???'
		kill ${FPID} && Log.warn "Killed build #$S - PID ${FPID}"
	done
	cd ${WORKSPACE}
	return 0
}

# JSON helper to skip JSON objects within a JSON object
function skipSub {
	typeset K=$1 V=$2 T
	if [[ ${K: -1:1} == ':' && $V == '{' ]]; then
		# print -u2 "# SKIP  $K"
		while read K V T ; do
			[[ $K == '},' || $K == '}' ]] && return 0
			skipSub $K $V
		done
		return 0
	fi
	return 1
}

# Since 'GitHub Pull Request Builder' does not expose PR details (even so they
# are internally available when this script is running), we need to fetch the
# pull infos by ourselves.
function getMergeInfo {
	typeset -n MI=$1
	typeset K V T
	typeset -x TZ=GMT 
	curl -Lsf https://api.github.com/repos/$2 2>/dev/null | while read K V T
	do
		# parse fetched JSON object ("key: value" pairs)
		[[ $K == '{' ]] && continue			# SOJO
		skipSub $K $V && continue
		[[ $K == '}' ]] && continue			# EOJO
		#print $K $V $T
		if [[ $K == '"state":' ]]; then
			MI[state]=${V:1:${#V}-3}
		elif [[ $K == '"closed_at":' ]]; then
			if [[ $V != 'null,' ]]; then
				MI[tclosed]=${V:1:${#V}-3}
				MI[tsclosed]=${ ${GDATE} --date="${MI[tclosed]}" '+%s' ; }
			fi
		elif [[ $K == '"merged_at":' ]]; then
			if [[ $V != 'null,' ]]; then
				MI[tmerged]=${V:1:${#V}-3}
				MI[tsmerged]=${ ${GDATE} --date="${MI[tmerged]}" '+%s' ; }
			fi
		elif [[ $K == '"merge_commit_sha":' ]]; then
			MI[sha]=${V:1:${#V}-3}
		elif [[ $K == '"merged":' ]]; then
			MI[merged]=${V:0:${#V}-1}
		elif [[ $K == '"mergeable":' ]]; then
			MI[mergeable]=${V:0:${#V}-1}
		fi
	done
}

function printInfo {
	typeset -n MINFO=$1
	(( $2 )) && Log.fatal "Exit code $2" && return 0

	Log.info 'Done.'
	typeset MSG= FMT='+%a, %d %b %Y %T %Z'
	if [[ -n ${MINFO[tsmerged]} ]]; then
		MSG+="PR #${ghprbPullId} got merged into ${ghprbTargetBranch} "
		MSG+="on ${ ${DATE} --date=@${MINFO[tsmerged]} "${FMT}" ; }"
	fi
	if [[ -n ${MINFO[tsclosed]} ]]; then
		if [[ ${MINFO[tsclosed]} == ${MINFO[tsmerged]} ]]; then
			MSG+="  and closed."
		elif [[ -z ${MINFO[tsmerged]} ]]; then
			MSG+="PR #${ghprbPullId} got closed unmerged "
			MSG+="on ${ ${DATE} --date=@${MINFO[tsclosed]} "${FMT}" ; }."
		else
			MSG+="  and closed "
			MSG+="on ${ ${DATE} --date=@${MINFO[tsclosed]} "${FMT}" ; }."
		fi
	fi
	[[ -n ${MSG} ]] && Log.info "${MSG}"
	return 0
}

function updateBranchStateLocal {
	typeset -n MINFO=$1
	(( $2 )) && Log.fatal "Exit code $2" && return 0

	getMergeInfo MINFO ontohub/ontohub/pulls/${ghprbPullId}
	[[ -z ${MINFO[tsmerged]} ]] && return 0		# nothing to track

	if [[ ! -d ${BR_STATE_DIR} ]]; then
		if ! mkdir -p ${BR_STATE_DIR} ; then
			Log.warn "Unable to create ${BR_STATE_DIR}" \
				" - PR ${ghprbPullId} state stays untracked."
			return 0
		fi
	fi
	typeset F="${BR_STATE_DIR}/${ghprbTargetBranch}"
	integer T
	[[ -s  $F ]] && T=$(<"$F") || T=0
	if (( T < MINFO[tsmerged] )); then
		print ${MINFO[tsmerged]} >"$F"
		# do, what a "nightly" job would do on success
	fi
	return 0
}

# prepare Test environment
function doSetup {
	killSamePRbuilds
	prepareDatabase
	prepareEsearch
	prepareHets
	setupDirs

	#integer C=300
	#while (( C > 0 )); do sleep 10; (( C-=10 )); print "Waiting $C s ..."; done
}

# run test suite
function doTests {
	export RAILS_ENV='test'

	# this shit pollutes ~ with .bundle - no way to put its cache anywhere else
	# even if --path is used. So we share the gems between all jobs.
	bundle install --quiet -j4 --path=${JENKINS_HOME}/gems

	# probably redundant because DBs are virgins
	redis-cli -s ${RSOCK#unix://} flushdb
	Log.info 'Running db:migrate:reset ...'
	bundle exec rake db:migrate:reset || true

	Log.info 'Starting tests ...'
	SPEC_OPTS="--color --format documentation" \
		CUCUMBER_OPTS="--color --format pretty" ELASTIC_TEST_PORT=${EPORT} \
		bundle exec rake
}

# post process test results/PR infos
function doReports {
	integer RES=$1
	typeset -A MINFO
	updateBranchStateLocal MINFO ${RES}
	printInfo MINFO ${RES}
	return ${RES}
}

trap tearDown EXIT
doSetup
doTests
doReports $?
