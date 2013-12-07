require 'date'

module Hets

  class HetsError < Exception; end
  class HetsDeploymentError < Exception; end
  class HetsNotFoundError < HetsError; end
  class HetsVersionOutdatedError < HetsError; end
  class HetsConfigDateFormatError < HetsError; end
  class HetsVersionDateFormatError < HetsError; end

  class Config
    attr_reader :path, :library_path, :stack_size

    def initialize
      yaml = YAML.load_file(File.join(Rails.root, 'config', 'hets.yml'))

      @path = first_which_exists yaml['hets_path']

      raise HetsNotFoundError, 'Could not find hets' unless @path

      unless is_compatible? yaml['hets_version_minimum_date']
        raise HetsVersionOutdatedError, 'The installed version of Hets is too old'
      end

      # Set hets environment variables for when the wrapper script is not used.
      yaml.each_pair do |key, value|
        if key != 'hets_path' and value.is_a? Array
          ENV[key.upcase] = first_which_exists value 
        end
      end

      @library_path = first_which_exists yaml['hets_lib']

      @stack_size = yaml['hets_stack_size'] || '1G'

      raise HetsDeploymentError, 'Hets library not found.' unless @library_path
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

    def first_which_exists(paths)
      paths.map { |path| File.expand_path path }.each do |path|
        return path if File.exists? path
      end

      nil
    end
  end

  # Runs hets with input_file and returns XML output file path.
  def self.parse(input_file, url_catalog = [], output_path = nil)
    @@config ||= Config.new

    # Arguments to run the subprocess
    args = [@@config.path, *%w( -o pp.xml -o xml --full-signatures -a none -v2 )]

    if output_path
      FileUtils.mkdir_p output_path
      args += ['-O', output_path]
    end

    args += ['-C', url_catalog.join(',')] unless url_catalog.empty?

    # Configure stack size
    args += ['+RTS', "-K#{@@config.stack_size}", '-RTS']

    # add the path to the input file as last argument
    args << input_file

    # Executes command with low priority
    Rails.logger.debug "Running hets with: #{args.inspect}"

    output = Subprocess.run :nice, *args

    if output.starts_with? '*** Error'
      # some error occured
      raise HetsError, output 
    elsif match = output.lines.last.match(/Writing file: (.+)/)
      # successful execution
      match[1]
    else
      # we can not handle this response
      raise HetsError, "Unexpected output:\n#{output}"
    end

  rescue Subprocess::Error => e
    output = e.output

    # Exclude usage message if exit status equals 2
    if e.status == 2 and output.include? 'Usage:'
      raise HetsError, output.split("Usage:").first
    else
      raise HetsError, e.message
    end
  end

  # Traverses a directory recursively, importing ontology file with supported
  # extension.
  #
  # @param user [User] the user that imports the ontology files
  # @param repo [Repository] Repository, the files shall be saved in
  # @param dir  [String] the path to the ontology library
  #
  def self.import_ontologies(user, repo, dir)
    find_ontologies(dir) { |path| import_ontology(user, repo, dir, path) }
  end

  # Imports an ontology in demand of a user.
  #
  # @param user [User] the user that imports the ontology file
  # @param repo [Repository] Repository, the files shall be saved in
  # @param path [String] the path to the ontology file
  #
  def self.import_ontology(user, repo, dir, path)
    relpath = File.relative_path(dir, path)
    puts relpath
    repo.save_file(path, relpath, "Added #{relpath}.", user)
  end

  def self.library_path
    (@@config ||= Config.new).library_path
  end


  private

  # Traverses a directory for ontologies with supported extensions recursively,
  # yielding their path.
  def self.find_ontologies(dir)
    Dir.glob("#{dir}/**/*.{#{Ontology::FILE_EXTENSIONS.join(',')}}").each { |path| yield path }
  end

end
