require File.expand_path('../watcher',  __FILE__)

class HetsWorkers < Watcher
  def group
    'hets'
  end

  def start_cmd
    hets_opts = ' ' << hets_server_options.join(' ')
    'exec nice hets -X' << hets_opts
  end

  def hets_server_options
    if ! defined?(AppConfig)
      require File.expand_path('../../../lib/environment_light', __FILE__)
    end
    old = AppConfig::setName('HetsSettings')
    AppConfig::load(false, 'config/hets.yml')
    AppConfig::setName(old)
    HetsSettings.server_options || []
  end

  def pid_file
    false
  end
end
