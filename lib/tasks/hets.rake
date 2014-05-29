namespace :hets do

  HETS_LOGFILE = Rails.root.join('log', 'hets.log')
  HETS_PIDFILE = Rails.root.join('tmp', 'pids', 'hets.pid')

  desc 'Start a hets server'
  task :start do
    if already_running?
      puts 'Hets is already running...'
    else
      pid = spawn("hets -X", [:out, :err] => [HETS_LOGFILE, 'w'])
      write_pid(pid)
      Process.detach(pid)
    end
  end

  desc 'Stop a running hets server'
  task :stop do
    if already_running?
      pid = fetch_pid
      system("kill #{pid}")
      remove_pidfile
    else
      puts 'Hets is not running...'
    end
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

end
