# SSH git

## Set up as a client (User)

* First you will need an account.

If you have one, you will need to add a SSH-key. This can be done by clicking on your username on the
ontohub webpage (top-bar) and selecting `SSH-Keys`.

There you will be able to add Public-Keys. If you are using the admin account please give the key a name corresponding
with your actual name (so we can identify them).

After this you need to set up your ssh key as you always do (either by naming it `id_rsa` in your `~/.ssh/` directory or by supplying a ssh config. [Here](http://man.cx/ssh_config) you can find the according manpage.

* `User` is: *git*
* `Host` is: `develop.ontohub.org` (or one of `['staging.ontohub.org', 'ontohub.org']`)

When you clone a repository the style would be: `git@develop.ontohub.org:<repository_name>.git` in which
you need to replace `<repository_name>` with the actual repository name. User of a ssh config will of course
replace the `git@develop.ontohub.org` portion with the `Host` supplied in the *ssh_config*.

## Server instructions for git/ssh integration of ontohub

### the git user

- `adduser git --home /srv/http/ontohub/shared/data/git_user/`
- `usermod -aG ontohub git`
- `usermod -g ontohub git`
- `chmod -R 660 .ssh/authorized_keys`
- `setfacl -R -m u:ontohub:rwx /srv/http/ontohub/shared/data/git_user/`
- `setfacl -d -m group:ontohub:rwx /srv/http/ontohub/shared/data/repositories`
- `setfacl -m group:ontohub:rwx /srv/http/ontohub/shared/data/repositories`

Also (for now) you will need to adjust the `sshd_config`, which is usually placed in */etc/ssh/sshd_config*,
by adding a line `StrictModes no`. See the reasons for this in [issue 304](https://github.com/ontohub/ontohub/issues/304#issuecomment-30078775).
