class Watcher
  attr_accessor :count

  def self.configure(&block)
    new.instance_eval(&block)
  end

  def initialize
    self.count = 0
  end

  def group
  end

  def start_cmd(*_args)
  end

  def pid_file
  end

  def watch(*args)
    self.count += 1

    if ! defined?(AppConfig)
      require File.expand_path('../../../lib/environment_light', __FILE__)
    end
    AppConfig::init

    God.watch do |w|
      w.dir           = AppConfig.root
      w.group         = group
      w.name          = "#{group}-#{@count}"
      w.pid_file      = pid_file if pid_file

      w.interval      = 30.seconds
      w.start         = start_cmd(*args)
      w.start_grace   = 10.seconds

      # Restart if memory gets too high
      w.transition(:up, :restart) do |on|
        on.condition(:memory_usage) do |c|
          c.above = 350.megabytes
          c.times = 2
        end
      end

      # Determine the state on startup
      w.transition(:init, true => :up, false => :start ) do |on|
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
end
