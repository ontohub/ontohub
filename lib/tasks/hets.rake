namespace :hets do
  HETS_LOGFILE = Rails.root.join('log', 'hets.log')
  HETS_PIDFILE = Rails.root.join('tmp', 'pids', 'hets.pid')

  desc "Create Hets Instance if neccessary"
  task :generate_first_instance => :environment do
    HetsInstance.first_or_create(name: 'localhost:8000', uri: 'http://localhost:8000')
  end


  desc 'Start a hets server'
  task :start do
    if already_running?
      puts 'Hets is already running...'
    else
      pid = spawn(hets_cmd, [:out, :err] => [HETS_LOGFILE, 'w'])
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

  desc 'Run a hets server synchronously'
  task :run do
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
    # Find first executable from those specified in settings_for_development.yml
    settings_for_development['paths']['hets']['executable'].
      map { |path| File.expand_path path }.
      find { |path| File.executable?(path) }
  end

  def hets_server_options
    load_environment_light_with_hets
    Settings.hets.server_options
  end

  def settings_for_development
    @settings_for_development ||=
      YAML.load_file(Rails.root.join('config',
                                     'settings_for_development.yml').to_s)
  end

  def load_environment_light_with_hets
    require Rails.root.join('lib', 'environment_light_with_hets.rb').to_s
  end
end
