# Productive Deployment

# Install an ontohub instance

This guide assumes a fresh and updated [Ubuntu 13.10 Server](http://www.ubuntu.com/start-download?distro=server&bits=64&release=latest) installation. Unless stated otherwise, the shell commandselast have to be executed as root. Make sure your filesystem supports ACLs.

_**Because we are using god this installation guide only works on Ubuntu.**_

## Install dependencies

### Repositories for redis and hets

    add-apt-repository -y ppa:chris-lea/redis-server
    add-apt-repository -y ppa:hets/hets
    apt-get update

### PostgreSQL, Apache, redis, Tomcat, Hets

    apt-get install -y postgresql apache2 apache2-dev libapr1-dev libaprutil1-dev libcurl4-openssl-dev \
                       git tomcat7 tomcat7-admin redis-server hets

#### Update hets to nightly version

    hets -update

### rbenv

    git clone git://github.com/sstephenson/rbenv.git /usr/local/rbenv

### adding rbenv to path

    echo '# rbenv setup' > /etc/profile.d/rbenv.sh
    echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh
    echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh
    echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

    chmod +x /etc/profile.d/rbenv.sh
    source /etc/profile.d/rbenv.sh

### Install ruby-build:

    pushd /tmp
      git clone git://github.com/sstephenson/ruby-build.git
      cd ruby-build
      ./install.sh
    popd

### Install ruby-aliases

    mkdir -p /usr/local/rbenv/plugins
      git clone git://github.com/tpope/rbenv-aliases.git \
      /usr/local/rbenv/plugins/rbenv-aliases
    rbenv alias --auto


### install Ruby 2.1.1

    rbenv install 2.1.1
    rbenv global 2.1.1

    rbenv rehash

### Passenger (Rails (Rack) module for Apache)

    gem install passenger
    passenger-install-apache2-module -a

### Users

    useradd -g ontohub -s /bin/sh -d /srv/http/ontohub/shared/data/git_user git

### Basic database setup

    su postgres -c psql
    create user ontohub;
    create database ontohub;
    grant all on database ontohub to ontohub;
    \q

## Install ontohub code on the server

This step enables you to maintain the settings of your own Ontohub instance in git and to deploy via capistrano.

Prepare the code directory as follows:

    mkdir -p /srv/http/ontohub
    chown ontohub:ontohub /srv/http/ontohub

### Deployment with capistrano

**Any commands in this section happen as user on your local machine.** It is assumed, you have a recent Ruby installation.

Be aware of the hostname, your production deployment machine uses. You should be able to login as user ontohub with an SSH key into your machine (`ssh ontohub@<hostname>`).

#### Clone

To clone the code and create a branch for your deployment, run:

    git clone https://github.com/ontohub/ontohub
    cd ontohub
    git checkout -b <hostname>
    gem install bundler
    bundle

#### Prepare own publicly accessable git repository

In the current capistrano configuration, you would need a publicly accessable git repository, the server fetches from. You can fork the ontohub repository on GitHub or create your own empty repository somewhere else.

Add your repository URL as a remote to your local ontohub clone:

    git remote add <remote-name> <url>

#### Adjust settings

##### Settings Files

Default settings can be found in the `config/settings.yml`.
Those are overridden by whatever is in the `config/settings/production.yml`,
which define defaults for the production environment. For your own deployment,
we recommend to create the file `config/settings.local.yml` to sepcify the
settings for your ontohub instance. That file overrides what is set in the
former files. The complete settings loading pipeline is
```
config/settings.yml
config/settings/#{environment}.yml
config/environments/#{environment}.yml
config/settings.local.yml
config/settings/#{environment}.local.yml
config/environments/#{environment}.local.yml
```
each overriding what was previously set.

You will find some **other `.yml` files** in the `config` directory, e.g.
`hets.yml`, but those **are supposed to be changed by developers only**,
because they contain settings which, for example, define (options for)
dependencies.

Further, you *can* override configuration that needs some computation or the
Rails environment, but **we recommend not to do this**. This is only needed
for special purposes, i.e. for a development/debugging instance running in
production mode. The pipeline is
```
config/environments/#{environment}.rb
config/environments/#{environment}.local.rb
```
each overriding what was previously set.

Not that the `*.local.*` files are ignored by git. If you want to have them in
your repository, add them with `git add filename --force`

##### Settings Validations

The settings which are in the listed `.yml` from the pipeline files are
validated, i.e. the data-types are checked and sometimes their values (email
address format, number range, etc.). If the validations fail, the Rails
application won't boot.

##### Changing Settings

Settings you most likely need to change include:
```yml
name
hostname
email
action_mailer.*
exception_notifier.exception_recepients
paths
```

Remember to adjust your `cp_keys` executable (see [Set up Git-SSH requirements](#set-up-git-ssh-requirements)) whenever you change the paths in the settings.
This is needed to have the git-ssh interaction working correctly.

##### Settings for deployment with capistrano

For deployment with capistrano, you need to change the hostname (in the
production environment) to the one of your deployment machine and the
capistrano `repo_url` setting in `config/deploy.rb` to your public repository
URL.

Now commit the settings:

    git commit -am 'Configured custom Ontohub instance.'

Push the changes to your own repo:

    git push <remote-name> <hostname>

You need a master branch. For now, just push your host-specific one to master.

    git push <remote-name> master

#### Deploy

You can deploy this codebase to your server with:

    bundle exec cap production deploy

(This should work&trade; now without any errors).


## Set up Git-SSH requirements

For security reasons, we don't directly manipulate the git-user's `authorized_keys` file in the Ontohub code.
Instead, we use a separate executable `cp_keys` which copies an `authorized_keys` file to the git-user's `.ssh` directory and prevails the correct permissions on that file.

The executable, which is located at `${paths.data}/.ssh/cp_keys`, is called with no arguments.
It copies the file `${paths.data}/.ssh/authorized_keys` to `${paths.data}/.ssh/authorized_keys`.
The target file's owner must be the git-user and the permissions must be set as usual for an `authorized_keys` file.

We prepared C-code for this task for Linux machines.
The source file is located at `script/cp_keys.c` and it contains an extensive comment on how to compile it and set it up.
It needs to be edited to have the paths from the `settings[.local].yml` hardcoded.

We also prepared a rake task to edit and compile the executable for you:
```
RAILS_ENV=production GIT_HOME=/home/git bundle exec rake git:compile_cp_keys
```
Although this takes some work off your shoulders, it also prints what you need to do.
This task is only for convenience.
If you want to have a secure environment, or if you don't run a standard (Ubuntu) Linux, we highly recommend to go through the file `script/cp_keys.c` and at least read its documenting comments.


## Configuration

### Change secret token

    bundle exec rake secret

This prints a long enough secret for verifying the integrity of signed cookies.
Save it to `config/settings/production.local.yml` or `config/settings.local.yml` at the key `secret_token` and keep that file secret.

If the `secret_token` leaked, you can replace it simply by invoking

    RAILS_ENV=production bundle exec rake secret:replace

It is important to do this in the correct environment because the settings files for the environment are searched for the token in descending order of priority.


### Apache

The [webserver configration page](https://github.com/ontohub/ontohub/tree/staging/doc/webserver_configuration.md) also provides details on Apache configuration.

#### mod_rewrite

    a2enmod rewrite

#### /srv directory

Be sure, the access to web applications inside `/srv` is granted. A stanza like the following has to be uncommented/included in your `/etc/apache2/apache2.conf`:

    <Directory /srv/>
      Options Indexes FollowSymLinks
      AllowOverride None
      Require all granted
    </Directory>

#### Passenger

Be sure, you use the right Ruby and passenger versions for the following file contents. They are determinable with `ruby -v` and `gem list passenger`.

Put the following inside `/etc/apache2/mods-available/passenger.load`:

    LoadModule passenger_module /usr/local/rbenv/versions/2.1.1/lib/ruby/gems/2.1.1/gems/passenger-4.0.49/ext/apache2/mod_passenger.so
PassengerRoot /usr/local/rbenv/versions/2.1.1/lib/ruby/gems/2.1.1/gems/passenger-4.0.39
PassengerRuby /usr/local/rbenv/versions/2.1.1/bin/ruby


#### Virtual host

This has to be placed into `/etc/apache2/sites-available/ontohub.conf`:

    <VirtualHost *:80>
      ServerName ontohub.org
      DocumentRoot /srv/http/ontohub/current/public

      <Directory /srv/http/ontohub/current/public>
        AllowOverride all
        Options -MultiViews
      </Directory>
    </VirtualHost>

Enable this configuration by `a2ensite ontohub`.

#### Restart

Apache has to be restarted. Run `service apache2 restart`.

### Ontohub god (process manager)

Ontohub uses god to manage the sidekiq processes. Sidekiq is used as a job queue for parallel execution of jobs like parsing ontologies.

Create `/etc/init/ontohub.conf` with the following contents:

    description "Ontohub god"
    start on (net-device-up and local-filesystems)
    stop on runlevel [016]

    respawn
    setuid ontohub
    env RAILS_ENV=production
    env HOME=/home/ontohub

    exec ~/god --no-daemonize --config-file config/god/app.rb --log-level debug --pid tmp/pids/god.pid --log log/god.log

    pre-stop exec ~/god terminate

And also `/home/ontohub/god`:

    #/bin/sh
    cd /srv/http/ontohub/current
    mkdir -p tmp/pids
    echo $$ > tmp/pids/god.pid
    exec /usr/local/rbenv/versions/2.1.1/bin/ruby bin/god $*

To make this script executable, run `chmod 755 /home/ontohub/god`.

Then start the defined service:

    service ontohub start

### Git user

In order to use the git functionallity of Ontohub there must be made some settings.
In the file `config/settings/production.yml` of the ontohub instance you can configured
which is the git user and in which group he is.
For example it looks like:

```YAML
git:
  user: git
  group: ontohub
```
Next we need the user on the System and must set the right permissions for him

- `adduser git --home /srv/http/ontohub/shared/data/git_user/`
- `usermod -aG ontohub git`
- `usermod -g ontohub git`
- `chmod -R 660 .ssh/authorized_keys`
- `setfacl -R -m u:ontohub:rwx /srv/http/ontohub/shared/data/git_user/`
- `setfacl -R -d -m group:ontohub:rwx /srv/http/ontohub/shared/data/repositories`
- `setfacl -R -m group:ontohub:rwx /srv/http/ontohub/shared/data/repositories`

the global bashrc which normally is located under `/etc/bash.bashrc` must contain

```bash
source /etc/profile.d/rbenv.sh
```

after that you have to set up the git Deamon which will be explained next.

### Git daemon

#### Directories and permissions

    cd /srv/http/ontohub/shared/data

    mkdir -p git_daemon git_ssh
    chown ontohub:ontohub git_daemon git_ssh
    setfacl -m u:ontohub:rwx,d:u:ontohub:rwx git_daemon git_ssh
    setfacl -m g:ontohub:rwx,d:g:ontohub:rwx git_daemon git_ssh

    mkdir -p git_user/.ssh
    chmod 770 git_user/.ssh
    touch git_user/.ssh/authorized_keys
    chmod 660 git_user/.ssh/authorized_keys
    chown -R git:ontohub git_user
    setfacl -Rm u:ontohub:rwx,d:u:ontohub:rwx git_user
    setfacl -Rm g:ontohub:rwx,d:g:ontohub:rwx git_user

    mkdir -p repositories
    chown ontohub:ontohub repositories
    setfacl -m u:ontohub:rwx,d:u:ontohub:rwx repositories
    setfacl -m g:ontohub:rwx,d:g:ontohub:rwx repositories

#### SSH access

SSH access is provided by the `git` user.
Every action started by a `git push` will be executed as this user, invoked
by the `~git/.ssh/authorized_keys`, which is manipulated by the `cp_keys` binary.
See [Set up Git-SSH requirements](#set-up-git-ssh-requirements) for details.

#### Service

Create an upstart script (i.e. `/etc/init/git-daemon.conf`):

    start on startup
    stop on shutdown
    setuid ontohub
    setgid webserv
    exec /usr/bin/git daemon \
        --reuseaddr \
        --export-all \
        --syslog \
        --base-path=/data/git/git_daemon
    respawn

Start the git daemon:

    service git-daemon start

### Installing Elasticsearch

If there's a new version on http://www.elasticsearch.org/download/, just replace the version number.

    + apt-get update
    + apt-get install openjdk-8-jre-headless -y
    wget https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.0.0/elasticsearch-2.0.0.deb
    
Before updating Elasticsearch to a new version it's recommended to get rid of the legacy version with `+ apt-get purge elasticsearch`.

The new version (`2.0.0`) appears to be a bit buggy with the start/stop service, because there's no `/etc/default/elasticsearch` at a new installation so you need to `echo 'ES_USER=esearch\nES_GROUP=esearch' | \ + tee /etc/default/elasticsearch`.
    
Before you can start Elasticsearch you need to replace the `elasticsearch` user with the `esearch` user. Thats because there are only 8-character-accounts on our machines allowed. To do this you need to

    + dpkg --unpack elasticsearch-2.0.0.deb
    + sed -r -e '/^#?ES_(USER|GROUP)=/ { s,^#,, ; s,=.*,=esearch, }'  -i /etc/default/elasticsearch.dpkg-new
    + sed -e '/rmdir/ s,$, || true,' -i /var/lib/dpkg/info/elasticsearch.postrm
    + dpkg --configure elasticsearch
    + update-rc.d elasticsearch defaults 95 10
    
To have the permissions for `/etc/elasticsearch` with the `esearch` user you need to 

    + find /etc/elasticsearch -type d -exec chmod 0755 {} +
    + find /etc/elasticsearch -type f -exec chmod 0644 {} +
    
Afterwards, if everything goes well, you can start it with

    + service elasticsearch start

If you want to test it, you can do

    curl http://localhost:9200

and you should get an elasticsearch cluster.
Now you have to import the ontology model, as ontohub user in /srv/http/ontohub/current do

    RAILS_ENV=production bundle exec rake environment elasticsearch:import:model CLASS=Ontology

#### Securing Elasticsearch

Elasticsearch versions 1.3.0-1.3.7 and 1.4.0-1.4.2 have a vulnerability in the Groovy scripting engine. The vulnerability allows an attacker to construct Groovy scripts that escape the sandbox and execute shell commands as the user running the Elasticsearch Java VM [[1]](http://www.elastic.co/guide/en/elasticsearch/reference/1.4/modules-scripting.html).
Also you should disable dynamic scripting completely [[2]](http://www.vanimpe.eu/2014/07/09/elasticsearch-vulnerability-exploit/).
To restrict elasticsearch, add the following lines to your `/etc/elasticsearch/elasticsearch.yml`:
```yml
script.groovy.sandbox.enabled: false
script.disable_dynamic: true
```

Next, allow to connect to elasticsearch (TCP Port 9200) only from localhost.

### Ontohub itself

Besides the configuration, which was already done during the deployment via capistrano, we need to create a user and import some basic data like categories.

#### Prepare shell

  su -l ontohub
  cd /srv/http/ontohub/current
  export RAILS_ENV=production
  alias run='ruby bundle exec'

#### Create first user

To gain a Rails console inside the Ontohub instance, you have to run the following:

    run rails c

Now create an admin user:

    me = User.new name: 'Alice', email: 'alice@example.org', password: 'changeme'
  me.admin = true
  me.confirm!
  exit

#### Import basic data

    run rake generate:metadata
  run rake import:logicgraph

# [For Developers] Deploy current code to ontohub.org

Checkout the ontohub.org branch in your local ontohub git repository clone, then execute:

    cap production deploy

## More Configuration Information

For more information about our server setup you can look at the [[Our productive configuration]] wiki page.
