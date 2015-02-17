# Productive Deployment

# Install an ontohub instance

This guide assumes a fresh and updated [Ubuntu 13.10 Server]ekastu(http://www.ubuntu.com/start-download?distro=server&bits=64&release=latest) installation. Unless stated otherwise, the shell commandselast have to be executed as root. Make sure your filesystem supports ACLs.

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

Change the hostname in `config/settings/production.yml` to the one of your deployment machine and the capistrano `repo_url` setting in `config/deploy.rb` to your public repository URL.

Also consider changing the name of your Ontohub instance, the outgoing mail address and the footer links right now.

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

## Configuration

### Change secret token

    rake secret

... and save it into `config/initializers/secret_token.rb`.


### Apache

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

  mkdir -p git_daemon
  chown ontohub:ontohub git_daemon
  setfacl -m u:ontohub:rwx,d:u:ontohub:rwx git_daemon
  setfacl -m g:ontohub:rwx,d:g:ontohub:rwx git_daemon

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

Adjust `/etc/ssh/sshd_config` by adding a line `StrictModes no`. The reasons for this is [issue 304](https://github.com/ontohub/ontohub/issues/304#issuecomment-30078775). Note, that this loosens security on your server (especially if it is a multi-user system).

#### Service

Create an upstart script (i.e. `/etc/init/git-daemon.conf`):

    start on startup
    stop on shutdown
    setuid nobody
    setgid nogroup
    exec /usr/bin/git daemon \
        --reuseaddr \
        --export-all \
        --syslog \
        --base-path=/srv/http/ontohub/shared/data/git_daemon
    respawn

Start the git daemon:

    service git-daemon start

### Installing Elasticsearch

If there's a new version on http://www.elasticsearch.org/download/, just replace the version number.

    sudo apt-get update
    sudo apt-get install openjdk-7-jre-headless -y
    wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.1.deb
    sudo dpkg -i elasticsearch-1.4.1.deb
    sudo service elasticsearch start

If you want to test it, you can do

    curl http://localhost:9200

and you should get an elasticsearch cluster.
Now you have to import the ontology model, as ontohub user in /srv/http/ontohub/current do

    RAILS_ENV=production bundle exec rake environment elasticsearch:import:model CLASS=Ontology

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

For more information about our serversetup you can look at the [[Our productive configuration]] wiki page.
