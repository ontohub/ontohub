require File.expand_path('../watcher',  __FILE__)

class HetsWorkers < Watcher
  def group
    'hets'
  end

  def start_cmd
    hets_opts = ' -X ' << hets_server_options.join(' ')
    hets_server = Array(HetsSettings['hets_path']).flatten
      .map { |path| File.expand_path path }.find { |path| File.exists?(path) }
    if ! hets_server
      raise ArgumentError, 'Unable to find a valid hets binary (put ' \
        << '"hets_path: full_path_to_hets" into your config/settings.local.yml)'
    end
    'exec nice ' << hets_server << hets_opts
  end

  def hets_server_options
    yml_file = File.join(RAILS_ROOT, 'config', 'hets.yml')
    YAML.load_file(yml_file)['server_options'] || []
  end

  def pid_file
    false
  end
end
