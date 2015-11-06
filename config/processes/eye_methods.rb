def sidekiq_process(proxy, name, queues, concurrency)
  queues_param = Array(queues).map { |q| " -q '#{q}'" }.join
  sidekiq_pid_file = "#{proxy.env['PID_DIR']}/sidekiq-#{name}.pid"
  sidekiq_log_file = "log/#{name}.log"
  sidekiq_start_command = %W(bin/sidekiq
                             -e #{proxy.env['RAILS_ENV']}
                             -c #{concurrency}
                             --pidfile #{sidekiq_pid_file}
                             --logfile #{sidekiq_log_file}
                             #{queues_param}).join(' ')

  proxy.process(name) do
    start_command sidekiq_start_command
    pid_file sidekiq_pid_file
    stdall sidekiq_log_file
    daemonize true
    stop_signals [:USR1, 0, :TERM, 10.seconds, :KILL]

    # Give the process some time for startup. Booting Rails can take some time.
    start_grace 10.seconds

    # Ensure the CPU is below 100% the last 5 times checked.
    check :cpu, every: 5.minutes, below: 100, times: 5
    # Ensure that the used memory is below the limit the last 5 times checked.
    check :memory, every: 5.minutes, below: 2048.megabytes, times: 5
  end
end

def hets_process(proxy, port)
  hets_pid_file = "#{proxy.env['PID_DIR']}/hets-#{port}.pid"
  hets_log_file = "log/hets-#{port}.log"

  proxy.process(:"hets-#{port}") do
    start_command hets_start_command(port)
    pid_file hets_pid_file
    stdall hets_log_file
    daemonize true
    stop_signals [:TERM, 10.seconds, :KILL]

    # Give the process some time for startup.
    start_grace 2.seconds

    # Ensure that Hets responds
    check :http,
      url: "http://localhost:#{port}/version",
      pattern: /\Av0.99, \d+\z/,
      every: 30.seconds,
      times: 1,
      timeout: 2.seconds
  end
end

def hets_start_command(port)
  options = hets_server_options.dup
  options << "--listen=#{port}" if port
  "#{hets_executable} --server #{options.join(' ')}"
end

def hets_server_options
  Settings.hets.server_options
end

def hets_executable
  Settings.hets.executable_path
end
