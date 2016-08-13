namespace :hets do
  HETS_LOGFILE = Rails.root.join('log', 'hets.log')
  HETS_PIDFILE = Rails.root.join('tmp', 'pids', 'hets.pid')

  desc "Create Hets Instance if neccessary"
  task :generate_first_instance => :environment do
    HetsInstance.first_or_create(name: 'localhost:8000',
                                 uri: 'http://localhost:8000',
                                 state: 'free',
                                 queue_size: 0)
  end

  desc 'Recreate Hets Instances from config'
  task :recreate_hets_instances => :environment do
    RakeHelper::Hets.recreate_instances
  end

  desc 'Start a hets server'
  task :start => :environment do
    if already_running?
      puts 'Hets is already running...'
    else
      pid = spawn(hets_cmd, [:out, :err] => [HETS_LOGFILE, 'w'])
      write_pid(pid)
      Process.detach(pid)
    end
  end

  desc 'Stop a running hets server'
  task :stop => :environment do
    if already_running?
      pid = fetch_pid
      system("kill #{pid}")
      remove_pidfile
    else
      puts 'Hets is not running...'
    end
  end

  desc 'Run a hets server synchronously'
  task :run => :environment do
    exec(hets_cmd)
  end

  def already_running?
    HETS_PIDFILE.exist?
  end

  def write_pid(pid)
    File.open(HETS_PIDFILE, 'a') do |f|
      f.write(pid)
    end
  end

  def fetch_pid
    pid = nil
    File.open(HETS_PIDFILE, 'r') do |f|
      pid = f.read
    end
    pid
  end

  def remove_pidfile
    FileUtils.rm HETS_PIDFILE
  end

  def hets_cmd
    "#{hets_binary} -X #{hets_server_options.join(' ')}"
  end

  def hets_binary
    Settings.hets.executable_path
  end

  def hets_server_options
    Settings.hets.server_options
  end
end
