Ontohub
=======

[![Build Status](https://travis-ci.org/ontohub/ontohub.png?branch=master)](https://travis-ci.org/ontohub/ontohub)
[![Code Climate](https://codeclimate.com/github/ontohub/ontohub.png)](https://codeclimate.com/github/ontohub/ontohub)
[![Coverage Status](https://coveralls.io/repos/ontohub/ontohub/badge.png)](https://coveralls.io/r/ontohub/ontohub)
[![Dependency Status](https://gemnasium.com/ontohub/ontohub.png)](https://gemnasium.com/ontohub/ontohub)


A web-based repository for distributed ontologies.

An ontology is a formal, logic-based description of the concepts and
relationships that are of interest to an agent (user or service) or to a
community of agents. The conceptual model of an ontology reflects a consensus,
and the implementation of an ontology is often used to support a variety of
applications such as web services, expert systems, or search engines. Therefore,
ontologies are typically developed in teams. Ontohub wants to make this
step as convenient as possible.

Ontohub aims at satisfying a subset of the requirements for an Open Ontology
Repository (OOR) and is being developed in close donnection with the Distributed
Ontology Language, which is part of the emerging Ontology Integration and
Interoperability standard (OntoIOp, ISO Working Draft 17347).  For more
information from this perspective, see [the Ontohub page in the Ontolog
wiki](http://ontolog.cim3.net/cgi-bin/wiki.pl?Ontohub).

This application started at the compact course [agile web development][0] given
by [Carsten Bormann][1] at the University of Bremen in March, 2012. The
concept and assignment came from [Till Mossakowski][2] and [Christoph
Lange][3] of the [AG Bernd Krieg-Brückner][4].

Initial developers are [Julian Kornberger][5] and [Henning Müller][6].

Documentation generated with yard is to be found on
[rubydoc.info](http://rubydoc.info/github/ontohub/ontohub/frames).

Installation
------------

These commands should work on Ubuntu 12.04. First of all you need a root shell.

### RVM with Ruby 2.0

Installation of [RVM](https://rvm.io/ "Ruby Version Manager"):

    apt-get install -y curl
    curl -L https://get.rvm.io | bash -s stable --ruby

If you have a desktop installation, you should "run command as a login shell" to
source rvm automatically as explained in https://rvm.io/integration/gnome-terminal/ .

### Apache2 with passenger

A dedicated HTTP server is only required for the production environment. (Skip
this section, if you are preparing your development setup.)

#### Installation

    apt-get install apache2 apache2-prefork-dev libapr1-dev
    gem install passenger
    passenger-install-apache2-module

#### Passenger Configuration

Depending on the installed ruby and passenger version you need to create a
`/etc/apache2/mods-available/passenger.load` with the LoadModule directive:

    LoadModule passenger_module /usr/local/rvm/gems/ruby-2.0.0-p<version>/gems/passenger-<version>/ext/apache2/mod_passenger.so

and a `/etc/apache2/mods-available/passenger.conf` with the global passenger
configuration:

    PassengerRoot /usr/local/rvm/gems/ruby-2.0.0-p<version>/gems/passenger-<version>
    PassengerRuby /usr/local/rvm/wrappers/ruby-2.0.0-p<version>/ruby

now enable the module an restart apache2:

    a2enmod passenger
    service apache2 restart

#### Virtual Host Configuration

    <VirtualHost *:80>
      ServerName ontohub.org
      DocumentRoot /srv/http/ontohub.org/current/public

      <Directory /srv/http/ontohub.org/public>
        AllowOverride all 
        Options -MultiViews
      </Directory>
    </VirtualHost>

### Git Daemon

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

### Tomcat with Solr

Tomcat with Solr is only required in the production environment.

    apt-get install tomcat6 tomcat6-admin
    
    cd /root/
    version=3.6.0
    wget http://apache.openmirror.de/lucene/solr/$version/apache-solr-$version.tgz
    tar xzf apache-solr-$version.tgz
    sudo cp apache-solr-$version/dist/apache-solr-solrj-$version.jar /var/lib/tomcat6/webapps/solr.war
    ln -s /srv/http/ontohub.org/current/solr/conf /var/lib/tomcat6/webapps/solr/

The war-Package should be automatically loaded.

### SQL Server

The master branch is (and should be) database independent. We are using
PostgreSQL in production and development.

#### PostgreSQL

    apt-get -y install postgresql

#### MySQL

You probably do not need this but we used MySQL in the new-model branch once and
these instructions are given for completeness. MariaDB has been tested, too.

The installation will prompt you for a password three times and you are expected
to press «enter» with an empty password field.

    apt-get -y install mysql-server libmysqlclient-dev

### Redis

[Redis](http://redis.io/) is a key-value store, in our setup used by [Sidekiq](http://sidekiq.org/) to
asynchronous background processing of long-lasting jobs.
Sidekiq requires Resque 2.4.0 or greater.

    add-apt-repository ppa:chris-lea/redis-server
    apt-get update
    apt-get install -y redis-server

### hets

    apt-add-repository ppa:hets/hets
    apt-add-repository "deb http://archive.canonical.com/ubuntu precise partner"
    apt-get update
    apt-get -y install hets-core subversion

    cd /lib/x86_64-linux-gnu/
    ln -s libpng12.so.0 libpng14.so.14

If you need the latest nightly build, just update hets (assure you have a
working internet connection):

    hets -update

Configuration
-------------

### Change secret token

    rake secret

... and save it into `config/initializers/secret_token.rb`.

### Hets environment variables

The Hets installation path and environment variables are to be set in
`config/hets.yml`. For ubuntu, it should be no change required.

### Allowed URI schemas

Allowed URI schemas are to be set in `config/initializers/ontohub_config.rb`.

Development
-----------

This part should be done with your own user (not as root).

### Clone with pushing permission

You need to create an SSH key pair (if you do not already have one) and upload
it to your Github account and then be added to the project by a project
administrator.

    git clone git@github.com:ontohub/ontohub.git

### Clone without pushing permission

You do not need to be a project member. Just clone it!

    git clone git://github.com/ontohub/ontohub.git

### Add yourself to the RVM group

    sudo adduser $USER rvm

You have to re-login to apply your group membership.

### Installation of dependencies

    sudo apt-get install libqtwebkit-dev
    cd ontohub
    bundle install

### Set up your database

After configuring your `config/database.yml` you have to create the tables:

    rake db:migrate:reset

### Seeds

Fill the database with dummy data:

    rake db:seed

### Start the rails server

Start the rails server and background processes.
The server will be available at http://localhost:3000/ until you stop it by pressing `CTRL+C`.

    script/start-development

Now you can log in as *admin@example.com* with password *foobar*.
*Alice, Bob, Carol, Dave, Ted* @example.com can also be used (with the same
password).

License
-------

Copyright © 2012 [Universität Bremen](http://www.uni-bremen.de/), released under
the [GNU AGPL 3.0](http://www.gnu.org/licenses/agpl-3.0.html) license.


[0]: http://www.tzi.org/~cabo/awe12
[1]: http://www.tzi.org/~cabo
[2]: http://www.tzi.org/~till
[3]: http://kwarc.info/clange
[4]: http://www.informatik.uni-bremen.de/agbkb
[5]: https://github.com/corny
[6]: http://henning.orgizm.net
