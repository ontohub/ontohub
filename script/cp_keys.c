#include <unistd.h>
#include <stdlib.h>

#define DATA_ROOT "/data/git"
#define GIT_HOME  "/home/git"

#define KEYS "/.ssh/authorized_keys"
#ifdef linux
#define	CP "/bin/cp"
#else
#define CP "/usr/bin/cp"
#endif

/*
 * The only purpose of this program is to copy the ssh authorized_keys file
 * written by the web application to ${DATA_ROOT}/.ssh/authorized_keys to the
 * ${GIT_HOME}/.ssh/authorized_keys file, whereby ${GIT_HOME} is the home
 * directory of the user running the git service (default ~git).
 *
 * Thus to get it actually work, the resulting binary needs to be owned by the
 * corresponding user running the git service and needs to be set suid (ssh
 * accepts authorized_keys files writable the owning user, only - i.e. just
 * setting the group write bit of the authorized_keys file simply doesn't work).
 *
 * Because suid stuff is always a "makes-me-nervous" thing, we hardcode the
 * source and destination as well as the binary to call, so that it cannot be
 * abused by malicious users - they would just cause a possibly redundant sync.
 *
 * As an alternative on a modern OS having a fine grained security model like
 * Solaris one could create a web2git RBAC role, add this role to the user
 * running the web service and add an appropriate entry to the exec_attr(4)
 * file, which allows web2git role to run the given command with euid of the
 * user running the git service and thus no suid bit is needed, e.g.:
 * web2git:suser:cmd:::/data/git/.ssh/cp_keys:uid=123:gid=456
 * On Linux with its coarse grained/ancient security models like apparmor
 * running scripts in a similar way is impossible, because when the related
 * interpreter gets execed, it doesn't inherit the capabilities/euid/... of the
 * script. However, if one has a lot of time and likes really complex setups,
 * he might be able to define appropriate SELinux contexts/policies/labels and
 * get script work in a similar way, however, we don't support that, i.e. we
 * leave such complex tasks to real security experts. Finally, ppl which do
 * not care a lot about  security might set the 'StrictModes no' in the related
 * sshd_config and than group writable authorized_keys files could be accepted.
 * But this is not recommended, since this setting applies to ALL users and NOT
 * ONLY to the authorized_keys files!
 *
 * Last but not least: The application expects the resulting binary in the
 * .ssh directory of the ${DATA_ROOT} - see app/models/key.rb as well as
 * lib/authorized_keys_manager.rb
 *
 * Steps to do (we assume the webservice is run by webservd:webservd and the
 * gitservice is run by the user git:webservd):
 *	0) edit cp_keys.c  - adjust DATA_ROOT and GIT_HOME wrt. your environment
 * 	1) gcc -o ${DATA_DIR}/.ssh/cp_keys cp_keys.c
 *	2) strip ${DATA_DIR}/.ssh/cp_keys
 *  3) chown git:webservd ${DATA_DIR}/.ssh/cp_keys
 *	4) chmod 4500 ${DATA_DIR}/.ssh/cp_keys
 *	5) optional for paranoid people add exec restricting withdrawn POSIX ACLs:
 *		chacl u::r-x,g::---,o::---,u:ontohub:r-x,u:webservd:--x,m::rwx \
 *			${DATA_DIR}/.ssh/cp_keys
 *	6) touch ${DATA_DIR}/.ssh/authorized_keys
 *	7) chown webservd:webservd ${DATA_DIR}/.ssh/authorized_keys
 *	8) chmod 0640 ${DATA_DIR}/.ssh/authorized_keys
 */
int
main(int argc, char *argv[])
{
    char *nenv[] = { NULL };
    char *nargv[] = { "cp", DATA_ROOT KEYS, GIT_HOME KEYS, NULL };
    int res = execve(CP, nargv, nenv);
    perror("execve");
    exit(res);
}
