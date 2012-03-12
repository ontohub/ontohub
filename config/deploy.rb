require 'bundler/capistrano'

# RVM
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
set :rvm_ruby_string, '1.9.3@ontohub'

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

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
    run "cd #{current_path} && RAILS_ENV=production rake resque:restart"
    run "cd #{current_path} && RAILS_ENV=production rake god:restart"
  end
end
