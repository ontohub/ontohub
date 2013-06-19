require 'date'

module Hets
  class HetsError < Exception; end
  class HetsNotFoundError < HetsError; end
  class HetsVersionOutdatedError < HetsError; end
  class HetsConfigDateFormatError < HetsError; end
  class HetsVersionDateFormatError < HetsError; end

  class Config
    attr_reader :path

    def initialize
      yaml = YAML.load_file(File.join(Rails.root, 'config', 'hets.yml'))

      @path = first_which_exists yaml['hets_path']

      raise HetsNotFoundError, 'Could not find hets' unless @path

      unless is_compatible? yaml['hets_version_minimum_date']
        raise HetsVersionOutdatedError, 'The installed version of Hets is too old'
      end

      yaml.each_pair do |key, value|
        ENV[key.upcase] = first_which_exists value if (key != 'hets_path' and value.is_a? Array)
      end
    end

  private

    # Checks Hets installation compatibility by its version date
    # 
    # * *Args* :
    # * - +minimum_date+ -> Minimum working hets version date
    # * *Returns* :
    # * - true if hets version minimum date prior or equal to actual hets version date
    # * - false otherwise
    def is_compatible?(minimum_date)
      # Read Hets version minimum date
      raise HetsConfigDateFormatError, 'Could not read hets version minimum date in YAML' unless minimum_date

      # Read Hets version date
      version = `#{@path} -V`
      version_date = begin
        Date.parse version.split.last
      rescue ArgumentError
        nil
      end

      raise HetsVersionDateFormatError, 'Could not read hets version date in output of `hets -V`' unless version_date

      # Return true if minimum date is prior or equal to version date
      return minimum_date <= version_date
    end

    def first_which_exists(array)
      array.each do |path|
        path = File.expand_path path
        return path if File.exists? path
      end

      nil
    end
  end

  # Runs hets with input_file and returns XML output file path.
  def self.parse(input_file, output_path = '')
    config = Config.new

    output_path = "-O \"#{output_path}\"" unless output_path.blank?

    command = "#{config.path} -o xml --full-signatures -v2 #{output_path} '#{input_file}' 2>&1"

    Rails.logger.debug command

    # nice runs the process with lower scheduling priority
    status = `nice #{command}`
    status = status.split("\n").last

    Rails.logger.debug status

    if $?.exitstatus != 0 or status.starts_with? '*** Error'
      raise HetsError.new(status)
    end

    status.split(': ').last
  end
end
