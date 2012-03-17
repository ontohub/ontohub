
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

after "deploy:update", "deploy:symlink_shared"
after :deploy, "deploy:cleanup"
