Ontohub
=======

A web-based repository for distributed ontologies.

An ontology is a formal, logic-based description of the concepts and
relationships that are of interest to an agent (user or service) or to a
community of agents. The conceptual model of an ontology reflects a consensus,
and the implementation of an ontology is often used to support a variety of
applications such as web services, expert systems, or search engines. Therefor,
ontologies are typically developed in teams. Ontohub wants to make this
step as convenient as possible.

Ontohub aims at satisfying a subset of the requirements for an Open Ontology Repository (OOR) and is being developed in close donnection with the Distributed Ontology Language, which is part of the emerging Ontology Integration and Interoperability standard (OntoIOp, ISO Working Draft 17347).  For more information from this perspective, see [the Ontohub page in the Ontolog wiki](http://ontolog.cim3.net/cgi-bin/wiki.pl?Ontohub).

This application started at the compact course [agile web development][0] given
by [Carsten Bormann][1] at the University of Bremen in March, 2012. The
concept and assignment came from [Till Mossakowski][2] and [Christoph
Lange][3] of the [AG Bernd Krieg-Brückner][4].

Initial developers are [Julian Kornberger][5] and [Henning Müller][6].

Installation
------------

These commands should work on Ubuntu 12.04. First of all you need a root shell.

### RVM with Ruby 1.9.3

Installation of [RVM](https://rvm.beginrescueend.com/ "Ruby Version Manager"):

    apt-get install -y build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion
    curl -L https://get.rvm.io | bash -s stable --ruby

If you have a desktop installation, you should "run command as a login shell" to
source rvm automatically as explained in https://rvm.io/integration/gnome-terminal/ .

### Apache2 with passenger

HttpServer is only required in the production environment.

#### Installation

    apt-get install apache2 apache2-prefork-dev libapr1-dev
    gem install passenger
    passenger-install-apache2-module

#### Passenger Configuration

Depending on the installed ruby and passenger version you need to create a `/etc/apache2/mods-available/passenger.load` with the LoadModule directive:

    LoadModule passenger_module /usr/local/rvm/gems/ruby-1.9.3-p<version>/gems/passenger-<version>/ext/apache2/mod_passenger.so

and a `/etc/apache2/mods-available/passenger.conf` with the global passenger configuration:

    PassengerRoot /usr/local/rvm/gems/ruby-1.9.3-p<version>/gems/passenger-<version>
    PassengerRuby /usr/local/rvm/wrappers/ruby-1.9.3-p<version>/ruby

now enable the module an restart apache2:

    a2enmod passenger
    service apache2 restart

#### Virtual Host Configuration

    <VirtualHost *:80>
      ServerName ontohub.orgizm.net
      DocumentRoot /srv/http/ontohub.orgizm.net/current/public

      <Directory /srv/http/ontohub.orgizm.net/public>
        AllowOverride all 
        Options -MultiViews
      </Directory>
    </VirtualHost>

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

### SQL SERVER

There are currently two possible sql servers. For the master branch, one needs
PostgreSQL; and for the new-model branch, MySQL.

#### PostgreSQL

    apt-get -y install postgresql

#### MySQL

The installation will prompt you for a password three times and you are expected
to press «enter» with an empty password field.

    apt-get -y install mysql-server libmysqlclient-dev

### Redis

    apt-get -y install redis-server

### hets

    apt-add-repository ppa:hets/hets
    apt-add-repository "deb http://archive.canonical.com/ubuntu precise partner"
    apt-get update
    apt-get -y install hets-core subversion

If you need the latest nightly build, just update hets (assure you have a
working internet connection):

    hets -update

Configuration
-------------

### Change secret token

    rake secret

... and save it into `config/initializers/secret_token.rb`.

### Hets environment variables

Hets environment variables and the extensions of files allowed for upload are
to be set in `config/hets.yml`.

### Allowed URI schemas

Allowed URI schemas are to be set in `config/initializers/ontohub_config.rb`.

### Clean upload cache

You can run the following command periodically to delete temporary files
from uploads.

    rails runner CarrierWave.clean_cached_files!

Development
-----------

This part should be done with your own user (not as root).

### Clone with pushing permission

You need to create an SSH-key and upload it to your Github account and then be
added to the project by a project administrator.

    git clone git@github.com:ontohub/ontohub.git

### Clone without pushing permission

You do not need to be a project member. Just clone it!

    git clone git://github.com/ontohub/ontohub.git

### Add yourself to the RVM group

    sudo adduser $USER rvm

### Installation in Local Machine

Login in again and run the following commands.

    cd ontohub
    bundle install

### Set up your database

After configuring your `config/database.yml` you have to create the tables:

    rake db:migrate:reset

### Solr and Resque

    rake sunspot:solr:start
    rake resque:work

### Seeds

Fill the database with dummy data:

    rake db:seed

### Start the rails server

Start the rails server. It will be available at http://localhost:3000/ until you
stop it by pressing `CTRL+C`.

    rails s

Now you can log in as *admin@example.com* with password *foobar*.
*Alice, Bob, Carol, Dave, Ted* @example.com can also be used.

### Stopping Solr and Resque

Resque has to be stopped with `CTRL+C` on the terminal you typed `rake
resque:work`. Solr is to be stopped as follows:

    rake sunspot:solr:stop

License
-------

Copyright © 2012 [Universität Bremen](http://www.uni-bremen.de/), released under the [GNU AGPL 3.0](http://www.gnu.org/licenses/agpl-3.0.html) license.


[0]: http://www.tzi.org/~cabo/awe12
[1]: http://www.tzi.org/~cabo
[2]: http://www.tzi.org/~till
[3]: http://kwarc.info/clange
[4]: http://www.informatik.uni-bremen.de/agbkb
[5]: https://github.com/corny
[6]: http://henning.orgizm.net
