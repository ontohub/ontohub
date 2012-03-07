require 'bundler/capistrano'

hostname = 'ontohub.orgizm.net'

set :application, 'ontohub'
set :scm, :git
set :repository, "git@github.com:digineo/#{application}.git"
set :deploy_to, "/srv/http/#{hostname}"
#set :bundle_without, [:development, :test]

set :user, application
set :use_sudo, false
set :deploy_via, :remote_cache

role :app, hostname
role :web, hostname
role :db,  hostname, :primary => true
