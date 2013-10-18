require 'bundler/capistrano'

# Set up Rails configuration
Rails = Struct.new(:env,:root).new
Rails.env  = ENV['RAILS_ENV'] || 'production'
Rails.root = Pathname.new(File.dirname(__FILE__) << "/..")

# Load application settings
require 'rails_config'
Settings = RailsConfig.load_files ["settings.yml","settings.local.yml", "settings/#{Rails.env}.yml"].map{|f| "#{Rails.root}/config/#{f}" }

hostname = Settings.hostname

set :application, 'ontohub'
set :scm, :git
set :repository, "git://github.com/#{application}/#{application}.git"
set :branch,     hostname
set :deploy_to, "/srv/http/ontohub"
set :shared_children, %w( public/uploads log tmp/pids )

set :user, 'ontohub'
set :use_sudo, false
set :deploy_via, :remote_cache

# RVM
require "rvm/capistrano"
set :rvm_type, :system
set :rvm_ruby_string, "ruby-2.0.0@#{application}"

role :app, hostname
role :web, hostname
role :db,  hostname, :primary => true

def rake_command(cmd)
  run "cd #{current_path} && bundle exec rake #{cmd}", :env => { :RAILS_ENV => rails_env }
end

Dir["#{Rails.root}/config/deploy/*.rb"].each{|f| load f }
