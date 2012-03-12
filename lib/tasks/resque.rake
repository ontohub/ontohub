require 'resque/tasks'

namespace :resque do
  task :setup => :environment do
    ENV['QUEUE'] = '*'
    Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
  end

  task :restart => :environment do
    pids = Array.new
    
    Resque.workers.each do |worker|
      pids << worker.to_s.split(/:/).second
    end
    
    if pids.size > 0
      system "kill -QUIT #{pids.join(' ')}"
    end
    
    system 'rm /var/run/god/resque*.pid'
  end
end
