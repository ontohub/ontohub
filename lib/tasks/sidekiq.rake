namespace :sidekiq do

  LOGFILE = Rails.root.join('log', 'sidekiq.log')
  PIDFILE = Rails.root.join('tmp', 'pids', 'sidekiq.pid')

  desc 'Start Sidekiq'
  task :start do
    system "bundle exec sidekiq -q default -q hets -q sequential -c 1 -v -L #{LOGFILE} -P #{PIDFILE} &"
  end

  desc 'Stop Sidekiq'
  task :stop do
    system "bundle exec sidekiqctl stop #{PIDFILE}"
  end
end
