require 'date'

module Hets

  class HetsError < ::StandardError; end
  class ExecutionError < HetsError; end
  class DeploymentError < HetsError; end
  class VersionOutdatedError < DeploymentError; end
  class ConfigDateFormatError < DeploymentError; end
  class VersionDateFormatError < DeploymentError; end
  class InvalidHetsVersionFormatError < DeploymentError; end

  class Config
    attr_reader :path, :library_path, :stack_size, :env

    def initialize
      yaml = YAML.load_file(File.join(Rails.root, 'config', 'hets.yml'))

      @path         = first_which_exists yaml['hets_path']
      @library_path = first_which_exists yaml['hets_lib']
      @stack_size   = yaml['stack_size'] || '1G'
      @env          = yaml['env'] || {}

      raise DeploymentError, 'Could not find hets'     unless @path
      raise DeploymentError, 'Hets library not found.' unless @library_path

      unless is_compatible? yaml['version_minimum_revision']
        raise VersionOutdatedError, 'The installed version of Hets is too old'
      end

      # Set hets environment variables
      %w( hets_lib hets_owl_tools ).each do |key|
        @env[key.upcase] = first_which_exists yaml[key]
      end

    end


    private

    # Checks Hets installation compatibility by its version date
    #
    # * *Args* :
    # * - +minimum_revision+ -> Minimum working hets version revision
    # * *Returns* :
    # * - true if hets version minimum revision smaller than or equal to actual hets version revision
    # * - false otherwise
    def is_compatible?(minimum_revision)
      # Read Hets version minimum revision
      raise ConfigDateFormatError, 'Could not read hets version minimum revision in YAML' unless minimum_revision

      # Read Hets version date
      version = `#{@path} -V`
      # revision starts with r-char and ends with revision number.
      version_revision = if version.split.last =~ /r(\d+)/
        $1 # the revision number
      else
        raise InvalidHetsVersionFormatError, "format is not valid: <#{version}>"
      end

      # Return true if minimum date is prior or equal to version date
      return minimum_revision.to_i <= version_revision.to_i
    end

    def first_which_exists(paths)
      paths.map { |path| File.expand_path path }.find do |path|
        File.exists? path
      end
    end
  end

  # Runs hets with input_file and returns XML output file path.
  def self.parse(input_file, url_catalog = [], output_path = nil, structure_only: false)

    # Arguments to run the subprocess
    args = [config.path, *%w( -o pp.xml -o xml --full-signatures -a none -v2 --full-theories )]

    if output_path
      FileUtils.mkdir_p output_path
      args += ['-O', output_path]
    end

    args += ['-s'] if structure_only

    args += ['-C', url_catalog.join(',')] unless url_catalog.empty?

    # Configure stack size
    args += ['+RTS', "-K#{config.stack_size}", '-RTS']

    # add the path to the input file as last argument
    args << input_file

    # Executes command with low priority
    Rails.logger.debug "Running hets with: #{args.inspect}"

    output = Subprocess.run :nice, *args, config.env

    if output.starts_with? '*** Error'
      # some error occured
      raise ExecutionError, output
    elsif (files = written_files(output.lines)).any?
      # successful execution
      files
    else
      # we can not handle this response
      raise ExecutionError, "Unexpected output:\n#{output}"
    end

  rescue Subprocess::Error => e
    output = e.output

    # Exclude usage message if exit status equals 2
    if e.status == 2 and output.include? 'Usage:'
      raise ExecutionError, output.split("Usage:").first
    else
      raise ExecutionError, e.message
    end
  end

  def self.config
    @@config ||= Config.new
  end

  def self.written_files(lines)
    lines.reduce([]) do |lines, line|
      file = written_file(line)
      lines << file if file
      lines
    end
  end

  def self.written_file(line)
    match = line.match(/Writing file: (?<file>.+)/)
    match[:file] if match
  end

end
