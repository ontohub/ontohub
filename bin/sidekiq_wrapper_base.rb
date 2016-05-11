require 'optparse'

RAILS_ROOT = File.expand_path('../..', __FILE__).freeze
SIDEKIQ_EXECUTABLE = File.join(RAILS_ROOT, 'bin/sidekiq').freeze
SIDEKIQ_BASE_ARGUMENTS = %W(#{SIDEKIQ_EXECUTABLE}
                            --environment #{ENV['RAILS_ENV'] || 'production'}
                            --timeout 15).freeze

# Parse options
def parse_options(filename)
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: #{filename} [options]"

    opts.on('-wMANDATORY', '--workdir=MANDATORY', 'Set work directory') do |w|
      options[:workdir] = w
    end
  end.parse!
  raise OptionParser::MissingArgument, '--workdir' if options[:workdir].nil?
  options
end

def run_process(options, arguments, name)
  Kernel.exec(*SIDEKIQ_BASE_ARGUMENTS, *arguments,
              '--pidfile', "#{File.join(options[:workdir], name)}.pid",
              '--logfile', "#{File.join(options[:workdir], name)}.log")
end
