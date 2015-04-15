require 'socket'
require 'timeout'
require 'vcr'

module FixturesGeneration
  # This is an abstract class. Subclasses need to implement
  # * files: the list of files to create fixtures to
  # * perform: the actual action to create the fixtures
  # * subdir: the subdirectory of the generated fixtures
  class BaseGenerator
    HETS_PATH = `which hets`.strip
    HETS_SERVER_ARGS = YAML.load(File.open('config/hets.yml'))['server_options']

    def initialize
      setup_vcr
    end

    def call
      on_outdated_cassettes do |file|
        perform(file)
      end
    end

    def outdated_cassettes
      files.select do |file|
        cassette = recorded_file(file)
        !FileUtils.uptodate?(cassette, Array(HETS_PATH))
      end
    end

    def with_running_hets(&block)
      with_running('hets',
                   "hets --server #{HETS_SERVER_ARGS.join(' ')}",
                   8000, 1, &block)
    end

    protected

    def setup_vcr
      unless VCR.configuration.cassette_library_dir
        VCR.configure do |c|
          c.cassette_library_dir = 'spec/fixtures/vcr'
          c.hook_into :webmock
        end
      end
    end

    def all_files_beneath(dir)
      globbed_files = Dir.glob(File.join(dir, '**/*'))
      globbed_files.select { |file| !File.directory?(file) }
    end

    def port_open?(ip, port, seconds=1)
      Timeout::timeout(seconds) do
        begin
          TCPSocket.new(ip, port).close
          true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          false
        end
      end
    rescue Timeout::Error
      false
    end

    def with_running(name, command, port, expected_startup_time, &block)
      need_to_start_server = !port_open?('127.0.0.1', port)
      if need_to_start_server
        puts "Starting #{name}"
        pid = fork { exec(command) }
        sleep expected_startup_time
      end
      block.call
    ensure
      if need_to_start_server
        puts "Stopping #{name}"
        Process.kill('INT', pid)
        Process.wait
      end
    end

    def absolute_filepath(file)
      Rails.root.join(file)
    end

    def cassette_file(file)
      # remove spec/fixtures/ontologies/ for cassette name
      cassette_filepath = file.split('/')[3..-1].join('/')
    end

    def hets_cassette_dir
      File.join('hets-out', subdir)
    end

    def cassette_path_in_fixtures(file)
      File.join(hets_cassette_dir, cassette_file(file))
    end

    def recorded_file(file)
      base = file.split('.')[0..-2].join('.')
      old_extension = File.extname(file)[1..-1]
      file = "#{base}_#{old_extension}.yml"
      File.join('spec', 'fixtures', 'vcr', cassette_path_in_fixtures(file))
    end

    def on_outdated_cassettes(&block)
      outdated_cassettes.each do |file|
        block.call(file)
      end
    end
  end
end
