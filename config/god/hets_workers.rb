require File.expand_path('../watcher',  __FILE__)

class HetsWorkers < Watcher
  def group
    'hets'
  end

  def start_cmd(port)
    load_hets_settings
    options = hets_server_options.dup
    options << "--listen=#{port}" if port
    "exec nice #{hets_executable} --server #{options.join(' ')}"
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
