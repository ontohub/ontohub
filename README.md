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

This application started at the compact course [agile web development][0] given
by [Carsten Bormann][1] at the University of Bremen in March, 2012. The
concept and assignment came from [Till Mossakowski][2] and [Christoph
Lange][3] of the [AG Bernd Krieg-Brückner][4].

Initial developers are [Julian Kornberger][5] and [Henning Müller][6].

Installation
------------

These commands should work on Ubuntu 11.04. First of all you need a root shell.

### RVM with Ruby 1.9.3

Installation of [RVM](https://rvm.beginrescueend.com/ "Ruby Version Manager"):

    bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)
    source ~/.bash_profile
    apt-get install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion
    rvm install 1.9.3

### Apache2 with passenger

    apt-get install apache2 apache2-prefork-dev libapr1-dev
    gem install passenger
    passenger-install-apache2-module

Depending on the installed ruby and passenger version you need to create a `/etc/apache2/mods-available/passenger.load` with the LoadModule directive:

    LoadModule passenger_module /usr/local/rvm/gems/ruby-1.9.3-p<version>/gems/passenger-<version>/ext/apache2/mod_passenger.so

and a `/etc/apache2/mods-available/passenger.conf` with the global passenger configuration:

    PassengerRoot /usr/local/rvm/gems/ruby-1.9.3-p<version>/gems/passenger-<version>
    PassengerRuby /usr/local/rvm/wrappers/ruby-1.9.3-p<version>/ruby

now enable the module an restart apache2:

    a2enmod passenger
    service apache2 restart

TODO: virtual host configuration

### Tomcat with Solr

    apt-get install tomcat6
    
    cd /root/
    version=3.5.0
    wget http://apache.openmirror.de/lucene/solr/$version/apache-solr-$version.tgz
    tar xzf apache-solr-$version.tgz
    sudo cp apache-solr-$version/dist/apache-solr-solrj-$version.jar /var/lib/tomcat6/webapps/solr.war

The war-Package should be automatically loaded.

### PostgreSQL

    apt-get install postgresql-server

### hets

    apt-add-repository ppa:hets/hets
    apt-add-repository "deb http://archive.canonical.com/ubuntu lucid partner"
    apt-get update
    apt-get install hets-core subversion

If you need the latest nightly build, just update hets:

    hets -update

Configuration
-------------

### Hets environment variables

Hets environment variables and the extensions of files allowed for upload are
to be set in `config/hets.yml`.

### Allowed URI schemas

Allowed URI schemas are to be set in `config/initializers/ontohub_config.rb`.

### Clean upload cache

    rails runner CarrierWave.clean_cached_files!


[0]: http://www.tzi.org/~cabo/awe12
[1]: http://www.tzi.org/~cabo
[2]: http://www.tzi.org/~till
[3]: http://kwarc.info/clange
[4]: http://www.informatik.uni-bremen.de/agbkb
[5]: https://github.com/corny
[6]: http://henning.orgizm.net
