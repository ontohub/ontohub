require File.expand_path('../watcher',  __FILE__)

class HetsWorkers < Watcher
  def group
    'hets'
  end

  def start_cmd
    load_hets_settings
    hets_opts = ' ' << hets_server_options.join(' ')
    "exec nice #{hets_executable} -X" << hets_opts
  end

  def pid_file
    false
  end

  protected

  def hets_server_options
    Settings.hets.server_options
  end

  def hets_executable
    Settings.hets.executable_path
  end

  def load_hets_settings
    require File.join(File.dirname(__FILE__), '..', '..', 'lib',
                      'environment_light_with_hets.rb')
  end
end
