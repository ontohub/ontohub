require File.expand_path('../watcher',  __FILE__)

class SidekiqWorkers < Watcher
  def group
    'sidekiq'
  end

  def start_cmd(queues, concurrency)
    queue_opt = Array(queues).map { |q| " -q '#{q}'" }.join
    %W(
      exec nice bin/sidekiq
      -c #{concurrency}
      --pidfile #{pid_file}
      --logfile log/sidekiq.log
      #{queue_opt}
    ).join(' ')
  end

  def pid_file
    if ! defined?(AppConfig)
      require File.expand_path('../../../lib/environment_light', __FILE__)
    end
    AppConfig::init
    File.join(AppConfig.root, "tmp/pids/sidekiq-#{count}.pid")
  end
end
