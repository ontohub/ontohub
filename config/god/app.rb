rails_env   = ENV['RAILS_ENV'] || "development"
rails_root  = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + "/../.."
num_workers = rails_env == 'production' ? 2 : 1

num_workers.times do |num|
  God.watch do |w|
    w.dir           = rails_root
    w.name          = "resque-#{num}"
    w.group         = 'resque'
    w.interval      = 30.seconds
    w.start         = "QUEUE=* nice rake resque:work"
    w.start_grace   = 10.seconds
    
    # Restart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 350.megabytes
        c.times = 2
      end
    end
    
    # Determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end
    
    # Determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
      end
      
      # Failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end
    
    # Start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_running) do |c|
        c.running = false
      end
    end
  end
end