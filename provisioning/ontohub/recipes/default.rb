# Ontohub install recipe, based on:
# https://github.com/ontohub/ontohub/blob/staging/script/install-on-ubuntu


### Dependencies
# Some are covered elsewhere: hets, postgresql
%w{build-essential openssl libreadline6 libreadline6-dev
   curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev
   libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev
   autoconf libc6-dev ncurses-dev automake libtool bison
   subversion libpq-dev redis-server libqtwebkit-dev}.each do |pkg|
  package pkg do
    action :install
  end
end

# Dependency debugging (can be merged with the list above)
# Fix for `require': cannot load such file -- mkmf (LoadError)
# http://stackoverflow.com/questions/7645918/require-no-such-file-to-load-mkmf-loaderror
# Fix ERROR: CMake is required to build Rugged
# Fix ERROR: pkg-config is required to build Rugged.
%w{ruby-dev cmake pkg-config}.each do |pkg|
  package pkg do
    action :install
  end
end


### Install Ontohub
# TODO: Workarounds
# sudo ln -s /lib/x86_64-linux-gnu/libpng12.so.0 /lib/x86_64-linux-gnu/libpng14.so.14

user 'ontohub'

directory '/opt/ontohub' do
  owner 'ontohub'
end

git '/opt/ontohub' do
  repository 'git://github.com/ontohub/ontohub.git'
  revision 'master'
  action :sync
  user 'ontohub'
end

gem_package 'bundler'

execute 'bundle-install' do
  cwd '/opt/ontohub'
  user 'ontohub'
  command '/usr/local/bin/bundle install --path /opt/ontohub/.bundler'
end


### Configure Ontohub
# TODO

