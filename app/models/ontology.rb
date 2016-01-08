class Ontology < ActiveRecord::Base

  # Ontohub Library Includes
  include Commentable
  include Metadatable

  # Ontology Model Includes
  include GraphStructures::SpecificFetchers::Mappings
  include IRIUrlBuilder::Includeable
  include Ontology::AssociationsAndAttributes
  include Ontology::Categories
  include Ontology::ClassMethodsAndScopes
  include Ontology::Distributed
  include Ontology::FileExtensions
  include Ontology::HetsOptions
  include Ontology::Import
  include Ontology::ImportMappings
  include Ontology::Mappings
  include Ontology::Oops
  include Ontology::OwlClasses
  include Ontology::Searching
  include Ontology::Sentences
  include Ontology::States
  include Ontology::Symbols
  include Ontology::Validations
  include Ontology::Versions

  # Multiple Class Features
  include Aggregatable

  class Ontology::DeleteError < StandardError; end

  delegate :permission?, to: :repository

  strip_attributes :only => [:name]

  def iri
    "#{Hostname.url_authority}#{locid}"
  end

  def repository
    @repository ||= Repository.find(repository_id)
  end

  def generate_name(name)
    match = name.match(%r{
      \A
      .+?
      :// # A uri has a separation between schema and hierarchy
      .+
      (?:/|\#)
        (?<filename>[^/]+) # Match filename after a slash/hash
      \z
    }x)
    if match
      filename = match[:filename].sub(/\.[\w\d]+\z/, '')
      capitalized_name = filename.split(/[_ ]/).map(&:capitalize).join(' ')
    else
      name
    end
  end

  def locid_for_child(child_name)
    child_name = child_name[1..-2] if child_name[0] == '<'
    child_name.include?('://') ? child_name : "#{locid}//#{child_name}"
  end

  def is?(logic_name)
    self.logic ? (self.logic.name == logic_name) : false
  end

  def owl?
    self.is?('OWL') || self.is?('OWL2')
  end

  def to_s
    name? ? name : iri
  end

  # Title for mappings
  def title
    name? ? iri : nil
  end

  def destroy_with_parent(user)
    if parent
      repository.delete_file(parent.path, user,
        "Delete #{Settings.OMS} #{parent}") do
        parent.destroy
      end
    else
      repository.delete_file(path, user,
        "Delete #{Settings.OMS} #{self}") do
        destroy
      end
    end
  end

  def destroy
    raise Ontology::DeleteError unless can_be_deleted?
    super
  end

  def can_be_deleted?
    if repository.is_destroying
      can_be_deleted_with_whole_repository?
    else
      can_be_deleted_alone?
    end
  end

  def can_be_deleted_alone?
    !is_imported_from_other_file?
  end

  def can_be_deleted_with_whole_repository?
    !is_imported_from_other_repository?
  end

  def contains_logic_translations?
    query, args = contains_logic_translations_query(self)
    pluck_select([query, *args], :logically_translated).size > 1
  end

  def combined_sentences
    affected_ontology_ids = [self.id] + imported_ontologies.pluck(:id)
    Sentence.original.where(ontology_id: affected_ontology_ids)
  end

  # list all sentences defined on this ontology,
  # those who are self defined and those which
  # are imported (ImpAxioms)
  def all_sentences
    Sentence.where(ontology_id: self)
  end

  def all_axioms
    Axiom.where(ontology_id: self)
  end

  def imported_sentences
    Sentence.
      where(ontology_id: self).
      where('imported = ?', true)
  end

  def basepath
    has_versions? ? current_version.basepath : read_attribute(:basepath)
  end

  def file_extension
    has_versions? ? current_version.file_extension : read_attribute(:file_extension)
  end

  def path
    "#{basepath}#{file_extension}"
  end

  def has_versions?
    current_version.present?
  end

  def file_in_repository
    repository.get_file(path)
  end

  # Uses where in order to force a Relation as a result
  def formality_levels
    FormalityLevel.joins(:ontologies).
      where(ontologies: {id: self})
  end

  def versioned_locid
    current_version.locid
  end

  # Checks if a file at the given commit (HEAD if nil) doesn't exist.
  def file_deleted?(commit_oid = nil)
    !has_file?(commit_oid)
  end

  # alias_method doesn't work for this one.
  def has_file?(commit_oid = nil)
    has_file(commit_oid)
  end

  def has_file(commit_oid = nil)
    if repository.is_head?(commit_oid)
      self[:has_file]
    else
      repository.path_exists?(path, commit_oid)
    end
  end
end
