require 'date'

module Hets

  EXTENSIONS = %w(casl clf clif dg dol het hol hs kif owl rdf spcf thy)
  EXTENSIONS_DIST = %w(casl dol hascasl het)


  class HetsError < Exception; end
  class HetsDeploymentError < Exception; end
  class HetsNotFoundError < HetsError; end
  class HetsVersionOutdatedError < HetsError; end
  class HetsConfigDateFormatError < HetsError; end
  class HetsVersionDateFormatError < HetsError; end

  class Config
    attr_reader :path, :library_path

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
  def self.parse(input_file, output_path = nil)
    @@config ||= Config.new

    if output_path
      FileUtils.mkdir_p output_path
      output_path = "-O \"#{output_path}\""
    end


    command = "#{@@config.path} -o xml --full-signatures -a none -v2 #{output_path} '#{input_file}' 2>&1"

    Rails.logger.debug command

    # Executes command with low priority
    output = `nice #{command}`

    # Exclude usage message if exit status equals 2
    if $?.exitstatus == 2 and output.include? 'Usage:'
      output = output.split("Usage:").first
    end

    output = output.split("\n").last
    Rails.logger.debug output

    # Raise error if exit status different from 0
    if $?.exitstatus != 0 or output.starts_with? '*** Error'
      raise HetsError.new(output)
    end

    return output.split(': ').last
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
    Dir.glob("#{dir}/**/*.{#{EXTENSIONS.join(',')}}").each { |path| yield path }
  end

end
