module Hets
  class HetsError < Exception; end
  class HetsDeploymentError < Exception; end

  class Config
    attr_reader :path

    def initialize
      yaml = YAML.load_file(File.join(Rails.root, 'config', 'hets.yml'))

      @path = Hets.first_existent_of yaml['hets_path']

      raise HetsError, 'Could not find hets' unless @path
      
      version = `#{@path} -V`
      raise ArgumentError, "Your version of hets is too old" if version.include?("2011")

      yaml.each_pair do |key, value|
        ENV[key.upcase] = Hets.first_existent_of value if key != 'hets_path'
      end
    end
  end

  def self.first_existent_of(paths)
    paths.each do |path|
      path = File.expand_path path
      return path if File.exists? path
    end
    nil
  end

  # Runs hets with input_file and returns XML output file path.
  def self.parse(input_file, output_path = '')
    config = Config.new

    output_path = "-O \"#{output_path}\"" unless output_path.blank?

    command = "#{config.path} -o xml -v2 #{output_path} '#{input_file}' 2>&1"

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

  # The path to the ontology library path
  #
  # @return [String] the path to the ontology library of Hets
  #
  def self.library_path
    settings = YAML.load_file(File.join(Rails.root, 'config', 'hets.yml'))
    library_paths = settings['hets_lib']
    library_path = Hets.first_existent_of library_paths
    raise HetsDeploymentError.new("*** Error: Hets library not found. ***") if library_path.nil?
    return library_path
  end

  # Traverses the Hets Lib directory recursively calling back on every ontology file
  #
  # @param onology_handling [Method] the way of handling ontology file paths
  # @param user [User] the user that handles the ontology file paths
  # @param library_path [String] the path to the ontology library
  #
  def self.handle_ontologies(ontology_handling, user, library_path)
    extensions.each do |extension|
      Dir.glob("#{library_path}/**/*.#{extension}").each do |file_path|
        ontology_handling.call(user, file_path, extension)
      end
    end
  end

  # Traverses the library directory recursively importing every ontology file
  #
  # @param user [User] the user that imports the ontology files
  # @param library_path [String] the path to the ontology library
  #
  def self.import_ontologies(user, library_path)
    handle_ontologies(method(:import_ontology), user, library_path)    
  end

  # Imports an ontology in demand of a user
  #
  # @param user [User] the user that imports the ontology file
  # @param file_path [String] the path to the ontology file
  # @param extension [String] the extension of the ontology file
  #
  def self.import_ontology(user, file_path, extension)
    puts file_path

    ontology = Ontology.new
    ontology.uri = "file://#{file_path}"
    ontology.name = File.basename(file_path, ".#{extension}")
    ontology.save!

    ontology_version = OntologyVersion.new
    ontology_version.user = user
    ontology_version.raw_file = File.open(file_path)
    ontology_version.ontology = ontology
    ontology_version.save!

    if redis
      ontology_version.async :parse
    else
      ontology_version.parse
    end
  end

end
