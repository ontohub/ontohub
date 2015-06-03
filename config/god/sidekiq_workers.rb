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
    File.join(RAILS_ROOT, "tmp/pids/sidekiq-#{count}.pid")
  end
end
