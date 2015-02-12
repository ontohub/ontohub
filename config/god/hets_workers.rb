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
    yml_file = File.join(RAILS_ROOT, 'config', 'hets.yml')
    YAML.load_file(yml_file)['server_options'] || []
  end

  def pid_file
    false
  end
end
