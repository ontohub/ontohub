require 'fileutils'
require File.expand_path('../../../lib/environment_light_with_hets.rb', __FILE__)
require File.expand_path('../eye_methods.rb', __FILE__)

Eye.config do
  logger "#{Rails.root}/log/eye.log"
end

def hets_queue_thread_count
  # One thread per configured hets instance, minus one for sequential
  # and one for priority_push.
  [1, Settings.hets.instance_urls.size - 2].max
end

Eye.application :ontohub do
  working_dir Rails.root.to_s
  env 'RAILS_ENV' => Rails.env
  env 'PID_DIR' => Rails.root.join('tmp', 'pids').to_s

  # Create PID dir
  FileUtils.mkdir_p(env['PID_DIR'])

  group :sidekiq do
    # Use a second queue for migration jobs which is checked less frequently.
    sidekiq_process self, :"sidekiq-hets", ['hets,5', 'hets-migration,1'],
                    hets_queue_thread_count

    # one worker for hets load balancing
    sidekiq_process self, :'sidekiq-hets-load-balancing', 'hets_load_balancing', 1

    # one worker for the default queue
    sidekiq_process self, :'sidekiq-default', 'default', 5

    # one worker for the sequential queue
    sidekiq_process self, :'sidekiq-sequential', 'sequential', 1

    sidekiq_process self, :'sidekiq-priority_push', 'priority_push', 1
  end

  group :hets do
    Settings.hets.instance_urls.each do |url|
      if url.match(%r{\Ahttps?://(localhost|127.0.0.1|0.0.0.0|::1)})
        hets_process self, URI(url).port
      end
    end
  end

  process :puma do
    ctrl_socket = 'unix:///tmp/pumactl.sock'
    home = Rails.root.join('..').to_s

    trigger :flapping, times: 10, within: 1.minute

    daemonize true
    pid_file "#{env['PID_DIR']}/puma.pid"
    stdall 'log/puma.log'

    start_command "#{home}/bin/puma -C config/puma.rb --control=#{ctrl_socket} --control-token="
    stop_command "#{home}/bin/pumactl --control-url=#{ctrl_socket} stop"
    restart_command "#{home}/bin/pumactl --control-url=#{ctrl_socket} restart"

    # just sleep this until process get up status
    # (maybe enough to puma soft restart)
    restart_grace 10.seconds

    # Ensure the CPU is below 80% the last 3 times checked.
    check :cpu, every: 30.seconds, below: 80, times: 3

    # Ensure that the used memory is below the limit
    # at least 3 out of the last 5 times checked.
    check :memory, every: 30.seconds, below: 256.megabytes, times: [3,5]
  end
end
