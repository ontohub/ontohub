module Hets
  class HetsError < Exception; end
  class HetsDeploymentError < Exception; end

  EXTENSIONS = %w(casl clf clif dg dol het hol hs kif owl rdf spcf thy)

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

  # The path to the Hets library path
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

  # Traverses the library recursively calling back on every ontology file
  #
  # @param library_path [String] the path to the ontology library
  #
  def self.find_ontologies(library_path)
    EXTENSIONS.each do |extension|
      Dir.glob("#{library_path}/**/*.#{extension}").each do |file_path|
        yield file_path, extension
      end
    end
  end

  # Traverses the library directory recursively importing every ontology file
  #
  # @param user [User] the user that imports the ontology files
  # @param library_path [String] the path to the ontology library
  #
  def self.import_ontologies(user, library_path)
    find_ontologies(library_path) do |file_path, extension|
      import_ontology(user, file_path, extension)
    end
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
    # TODO Use custom ontology iris detached from the local file system
    ontology.iri = "file://#{file_path}"
    ontology.name = File.basename(file_path, ".#{extension}")
    begin
      ontology.save!
    rescue
      puts "ERROR: " + ontology.name + " <" + ontology.iri + ">"
      return
    end

    ontology_version = OntologyVersion.new
    ontology_version.user = user
    ontology_version.raw_file = File.open(file_path)
    ontology_version.ontology = ontology
    ontology_version.save!
    ontology_version.async :parse
  end

end
