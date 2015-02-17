# Developer Installation on Ubuntu

*This guide is for Ubuntu 14.04*

## Ruby (rbenv and ruby-build)

We recommend to use rbenv for managing
ruby on your system. Sam Stephenson gives a good
installation guide on the [Github page](https://github.com/sstephenson/rbenv#installation).
But here is what you have to do:

- `$ git clone https://github.com/sstephenson/rbenv.git ~/.rbenv`

Now we just have to tell the shell to use rbenv
to determine the Ruby Version.

- `$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc`
- `$ echo 'eval "$(rbenv init -)"' >> ~/.bashrc`

If you are using **zsh**, just replace the *.bashrc* with
*.zshrc* (or the config file for your shell, if you are using
different one).

if you restart your shell you could check if rbenv is installed correctly
with:

```
$ type rbenv
#=> "rbenv is a function"
````

to install a ruby version, first install ruby-build with
```
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
```
and then use

```
rbenv install 2.1.3p242
```
### rbenv aliases

As we use the *.ruby-version* to specify ontohubs ruby version,
you might need rbenv aliases in order to use the **right**
local version.

- `mkdir -p ~/.rbenv/plugins`
- `git clone git://github.com/tpope/rbenv-aliases.git \
  ~/.rbenv/plugins/rbenv-aliases`
- `rbenv alias --auto`

## PostgreSQL
```
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main > /etc/apt/sources.list.d/pgdg.list'
sudo apt-get install -y postgresql-9.3
sudo sed -i 's/de_DE/en_US/' /etc/postgresql/9.3/main/postgresql.conf
sudo service postgresql reload
```

Next, we should allow the connection to the database with the postgres user. Edit the `/etc/postgresql/9.3/main/pg_hba.conf` as super user. Somewhere on the bottom there is the line
```
local   all             postgres                                peer
```
change it to
```
local   all             postgres                                trust
```

After this we should create the config directory for postgres:

- `initdb /usr/local/var/postgres -E utf8`

Now when you use `psql` you should be connected to the
database (`\q` lets you quit).

Now we have to create the user to be used by ontohub in development:

- `createuser -d -w -s postgres`

You'll also (probably) need to create the two databases:

- `createdb ontohub_development`
- `createdb ontohub_test`

## gems

Switch to the directory where you clone ontohub.

We use **capybara-webkit** for integration testing. This gem needs a **qt**-Engine
on the system, so we will have to install one:

- `sudo apt-get install libqtwebkit-dev`

Now we can actually start installing the necessary gems:

- `gem install bundler`
- `bundle install`

## redis

In order for resque to work, we need to install redis.

```
add-apt-repository ppa:chris-lea/redis-server
apt-get update
apt-get install -y redis-server
```

## hets

The Heterogenous Toolset is needed to perform Operations during Ontology import.
To Install it you have to do the following steps:

```
apt-add-repository ppa:hets/hets
apt-add-repository "deb http://archive.canonical.com/ubuntu precise partner"
apt-get update
apt-get -y install hets-core subversion

cd /lib/x86_64-linux-gnu/
ln -s libpng12.so.0 libpng14.so.14
```

If you need the latest nightly build, just update hets (assure you have a working internet connection):

```
hets -update
```

## setup

In ontohub directory:

- `rake db:migrate:reset`
- `rake sunspot:solr:start`
- `rake resque:work`

Now you should be ready...
