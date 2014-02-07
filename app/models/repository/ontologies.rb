module Repository::Ontologies
  extend ActiveSupport::Concern

  # list all failed versions, grouped by their errors
  def failed_ontology_versions
    ontologies
    .without_parent
    .map{|o| o.versions.last}
    .compact
    .select{|v| v.state!="done"}
    .group_by(&:state_message)
  end

  def primary_ontology(path)
    path ||= ''
    onto = ontologies.where(basepath: File.basepath(path)).first
    while !onto.nil? && !onto.parent.nil?
      onto = onto.parent
    end

    onto
  end

  # Traverses a directory recursively, importing ontology file with supported
  # extension.
  #
  # @param user [User] the user that imports the ontology files
  # @param dir  [String] the path to the ontology library
  #
  def import_ontologies(user, dir)
    Dir.glob("#{dir}/**/*.{#{Ontology::FILE_EXTENSIONS.join(',')}}").each do |path|
      import_ontology(user, dir, path)
    end
  end

  # Imports an ontology in demand of a user.
  #
  # @param user [User] the user that imports the ontology file
  # @param repo [Repository] Repository, the files shall be saved in
  # @param path [String] the path to the ontology file
  #
  def import_ontology(user, dir, path)
    relpath = File.relative_path(dir, path)
    save_file(path, relpath, "Added #{relpath}.", user)
  end

end
