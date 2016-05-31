RAILS_ROOT = File.join(File.dirname(__FILE__), '../..')
RAILS_ENV = ENV['RAILS_ENV'] || 'production'
SVCADM = '/usr/sbin/svcadm'

Eye.config do
  logger "#{RAILS_ROOT}/log/eye.log"
end

Eye.application :ontohub do
  working_dir RAILS_ROOT
  env 'RAILS_ENV' => RAILS_ENV
  env 'PID_DIR' => File.join(RAILS_ROOT, 'tmp/pids').to_s

  %i(git hets puma sidekiq).each do |service|
    process service do
      daemonize false
      pid_file File.join(env['PID_DIR'], "#{service}.pid")
      start_command "#{SVCADM} enable -s #{service}"
      stop_command "#{SVCADM} disable -s #{service}"
    end
  end
end
