require File.expand_path('../watcher',  __FILE__)

class HetsWorkers < Watcher
  def group
    'hets'
  end

  def start_cmd(hets_opts = [])
    hets_opts =
      if hets_opts && !hets_opts.empty?
        ' ' << hets_opts.join(' ')
      else
        ''
      end
    'exec nice hets -X' << hets_opts
  end

  def pid_file
    false
  end
end
