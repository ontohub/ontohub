RAILS_ROOT = File.join(File.dirname(__FILE__), '../..')
RAILS_ENV = ENV['RAILS_ENV'] || 'production'
SVCADM = '/usr/sbin/svcadm'

SIDEKIQ_BASE = '/var/sidekiq'
SERVICES_PIDS = {git: File.join(env['PID_DIR'], 'git.pid'),
                 hets: File.join(env['PID_DIR'], 'git.pid'),
                 puma: File.join(env['PID_DIR'], 'puma.pid'),
                 sidekiq: File.join(SIDEKIQ_BASE, 'master.pid')}

Eye.config do
  logger "#{RAILS_ROOT}/log/eye.log"
end

Eye.application :ontohub do
  working_dir RAILS_ROOT
  env 'RAILS_ENV' => RAILS_ENV
  env 'PID_DIR' => File.join(RAILS_ROOT, 'tmp/pids')

  SERVICES_PIDS.each do |service, pidfile|
    process service do
      daemonize false
      pid_file pidfile
      start_command "#{SVCADM} enable -s #{service}"
      stop_command "#{SVCADM} disable -s #{service}"
    end
  end
end
