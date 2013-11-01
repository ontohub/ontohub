
namespace :sidekiq do
  def kill(signal)
    run "for file in `find #{current_path}/tmp/pids -name 'sidekiq-*.pid'`; do kill -s #{signal} `cat $file`; done"
  end

  desc "Stop sidekiq gracefully"
  task :stop, roles: :app do
    kill 'SIGTERM'
  end
end

after "deploy:restart", "sidekiq:stop"
