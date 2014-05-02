namespace :server do

  desc 'Start development environment'
  task :start do
    Rake::Task['sunspot:solr:start'].invoke
    Rake::Task['sidekiq:start'].invoke
    Rake::Task['server:rails:start'].invoke
  end

  desc 'Stop development environment'
  task :stop do
    Rake::Task['sunspot:solr:stop'].invoke
    Rake::Task['sidekiq:stop'].invoke
    Rake::Task['server:rails:stop'].invoke
  end

  namespace :rails do
    SERVER_PID_FILE = Rails.root.join('tmp', 'pids', 'server.pid')

    desc 'Start rails server'
    task :start do
      system 'rails server 2>&1 > /dev/null &'
    end

    desc 'Stop rails server'
    task :stop do
      system "kill -INT $(cat #{SERVER_PID_FILE})"
    end
  end

end
