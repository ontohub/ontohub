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
  include Ontology::Import
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
  delegate :unproven_theorems, to: :current_version

  strip_attributes :only => [:name, :iri]

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

  def iri_for_child(child_name)
    child_name = child_name[1..-2] if child_name[0] == '<'
    child_name.include?("://") ? child_name : "#{iri}?#{child_name}"
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

  def is_imported?
    import_mappings.present?
  end

  def is_imported_from_other_repository?
    import_mappings_from_other_repositories.present?
  end

  def imported_by
    import_mappings.map(&:source)
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
    !is_imported?
  end

  def can_be_deleted_with_whole_repository?
    !is_imported_from_other_repository?
  end

  def imported_ontologies
    fetch_mappings_by_kind(self, 'import')
  end

  def contains_logic_translations?
    query, args = contains_logic_translations_query(self)
    pluck_select([query, *args], :logically_translated).size > 1
  end

  def direct_imported_ontologies
    ontology_ids = Mapping.where(target_id: self, kind: 'import').
      pluck(:source_id)
    Ontology.where(id: ontology_ids)
  end

  def combined_sentences
    affected_ontology_ids = [self.id] + imported_ontologies.pluck(:id)
    Sentence.where(ontology_id: affected_ontology_ids)
  end

  # list all sentences defined on this ontology,
  # those who are self defined and those which
  # are imported (ImpAxioms)
  def all_sentences
    Sentence.unscoped.
      where(ontology_id: self).
      where('imported = ? OR imported = ?', true, false)
  end

  def imported_sentences
    Sentence.unscoped.
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

  protected

  def import_mappings
    Mapping.where(source_id: id, kind: 'import')
  end

  def import_mappings_from_other_repositories
    import_mappings.select { |l| l.target.repository != repository }
  end
end
