namespace :resque do  
  desc "Stop resque"
  task :stop do
    rake_command 'resque:stop'
  end
end

before "deploy:update", "resque:stop"
