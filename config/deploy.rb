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
  end
  
  desc "Symlink shared configs and folders on each release."
  task :symlink_shared, :roles => :app, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"
    run "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/"
  end
end


def rake_command(cmd)
  run "cd #{current_path} && bundle exec rake #{cmd}", :env => { :RAILS_ENV => rails_env }
end

namespace :resque do  
  desc "Stop resque"
  task :stop do
    rake_command 'resque:stop'
  end
end

namespace :sunspot do
  desc "Reindex all solr models"
  task :reindex do
    rake_command 'sunspot:reindex'
  end
end

# https://makandracards.com/makandra/1431-resque-+-god-+-capistrano
namespace :god do
  def god_is_running
    !capture("#{god_command} status >/dev/null 2>/dev/null || echo 'not running'").start_with?('not running')
  end

  def god_command
    "cd #{current_path}; bundle exec god"
  end

  desc "Start god"
  task :start do
    run "#{god_command} -c config/god/app.rb", :env => environment = { :RAILS_ENV => rails_env }
  end

  desc "Stop god"
  task :stop do
    if god_is_running
      run "#{god_command} terminate"
    end
  end

  desc "Test if god is running"
  task :status do
    puts god_is_running ? "God is running" : "God is NOT running"
  end
end

before "deploy:update", "god:stop"
before "deploy:update", "resque:stop"
after "deploy:update", "deploy:symlink_shared"
after "deploy:update", "god:start"
after :deploy, "deploy:cleanup"

