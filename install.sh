#/bin/bash

# Installing Dependencies
sudo apt-add-repository ppa:hets/hets
sudo apt-add-repository "deb http://archive.canonical.com/ubuntu precise partner"
sudo apt-get update

sudo apt-get install -y build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion postgresql redis-server hets-core libqtwebkit-dev

curl -L https://get.rvm.io | bash -s stable --ruby
source $HOME/.rvm/scripts/rvm
echo "source $HOME/.rvm/scripts/rvm" >> ~/.bashrc

# Work Arounds
sudo ln -s /lib/x86_64-linux-gnu/libpng12.so.0 /lib/x86_64-linux-gnu/libpng14.so.14

# Installing Ontohub
cd $HOME
mkdir Workspace
cd Workspace
git clone git@github.com:ontohub/ontohub.git

sudo addgroup rvm
sudo adduser $USER rvm

cd ontohub
gem install bundler
bundle install

# Configuring Ontohub
SECRET=`rake secret`
echo "Ontohub::Application.config.secret_token = '$SECRET'" > config/initializers/secret_token.rb

rake db:migrate:reset
rake sunspot:solr:start
rake resque:work&
rake db:seed

rails s&

