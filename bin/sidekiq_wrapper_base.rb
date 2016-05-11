require 'optparse'

RAILS_ROOT = File.expand_path('../..', __FILE__).freeze
SIDEKIQ_EXECUTABLE = File.join(RAILS_ROOT, 'bin/sidekiq').freeze
SIDEKIQ_BASE_ARGUMENTS =
  %W(#{SIDEKIQ_EXECUTABLE}
     --environment #{ENV['RAILS_ENV'] || 'production'}).freeze

# Parse options
def parse_options(filename)
  options = {workdir: Dir.pwd,
             timeout: 15}
  OptionParser.new do |opts|
    opts.banner = "Usage: #{filename} [options]"

    opts.on('-wMANDATORY', '--workdir=MANDATORY',
            'Set work directory (default: CWD)') do |w|
      options[:workdir] = w
    end

    opts.on('-tMANDATORY', '--timeout=MANDATORY',
            'Set timeout in seconds until sidekiq jobs are killed at '\
            "sidekiq shutdown (default: #{options[:timeout]})") do |t|
      options[:timeout] = t
    end
  end.parse!
  options
end

def run_process(options, arguments, name)
  Kernel.exec(*SIDEKIQ_BASE_ARGUMENTS, *arguments,
              '--timeout', options[:timeout].to_s,
              '--pidfile', "#{File.join(options[:workdir], name)}.pid",
              '--logfile', "#{File.join(options[:workdir], name)}.log")
end
