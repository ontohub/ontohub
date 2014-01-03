require 'bundler/capistrano'
require File.dirname(__FILE__) << "/../lib/environment_light"

hostname = Settings.hostname

set :application, 'ontohub'
set :scm, :git
set :repository, "git://github.com/#{application}/#{application}.git"
set :branch,     hostname
set :deploy_to, "/srv/http/ontohub"
set :shared_children, %w( data log tmp/pids )

set :user, 'ontohub'
set :use_sudo, false
set :deploy_via, :remote_cache

# RVM
require "rvm/capistrano"
set :rvm_type, :system
set :rvm_ruby_string, "ruby-2.1.0@#{application}"

role :app, hostname
role :web, hostname
role :db,  hostname, :primary => true

def rake_command(cmd)
  run "cd #{current_path} && bundle exec rake #{cmd}", :env => { :RAILS_ENV => rails_env }
end

Dir["#{Rails.root}/config/deploy/*.rb"].each{|f| load f }
