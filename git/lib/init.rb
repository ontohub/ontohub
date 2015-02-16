begin
  require File.expand_path('../../../lib/environment_light', __FILE__)

  if AppConfig::getName != 'Settings'
    AppConfig::setName('Settings')
  end
  AppConfig::load
  if ! Settings.git
    Settings.git = RailsConfig::Options.new
  end
  if ! Settings.git.data_dir
    Settings.git.data_dir = File.join(AppConfig.root, 'tmp', 'data')
  end
  require File.join(AppConfig.root, 'config/initializers/paths')

  # extend the load path
  $:.unshift File.dirname(__FILE__)
  $:.unshift File.join(AppConfig.root, 'lib')

  require 'logger'

  # Configuration #
  #################

  Settings.redis_namespace = 'ontohub'
  if (Settings.git.log_dir )
    dir = Settings.git.log_dir.to_s
    if dir[0] != '/'
       dir = File.join(AppConfig.root, f)
    end
  else
     dir = File.join(AppConfig.root, 'log')
  end
  Settings.git.log_dir = dir.to_s
  Settings.git.logger = Logger.new File.join(dir, 'git.log')
  PathsInitializer.perform_initialization(Settings)

  require 'ontohub_net'
rescue ScriptError => e
  STDERR.puts <<-ERROR
We encountered a hard system error while processing
your git-interaction attempt.
The git command was not processed; your data is safe.
Please contact and inform an administrator of this issue.
  ERROR
  exit 1
end
