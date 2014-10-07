class Ontology < ActiveRecord::Base

  # Ontohub Library Includes
  include Commentable
  include Metadatable

  # Ontology Model Includes
  include Ontology::Import
  include Ontology::Scopes
  include Ontology::States
  include Ontology::Versions
  include Ontology::Entities
  include Ontology::Sentences
  include Ontology::Links
  include Ontology::Distributed
  include Ontology::Categories
  include Ontology::Oops
  include Ontology::Projects
  include Ontology::Tools
  include Ontology::Tasks
  include Ontology::LicenseModels
  include Ontology::FileExtensions
  include Ontology::Searching
  include GraphStructures::SpecificFetchers::Links

  # Multiple Class Features
  include Aggregatable

  class Ontology::DeleteError < StandardError; end

  belongs_to :language
  belongs_to :logic, counter_cache: true
  belongs_to :ontology_type
  belongs_to :repository
  belongs_to :formality_level

  has_many :entity_groups
  has_many :alternative_iris, dependent: :destroy
  has_many :source_links, class_name: 'Link', foreign_key: 'source_id', dependent: :destroy
  has_many :target_links, class_name: 'Link', foreign_key: 'target_id', dependent: :destroy

  has_and_belongs_to_many :license_models

  attr_accessible :iri, :name, :description, :acronym, :documentation,
                  :logic_id,
                  :category_ids,
                  :acronym,
                  :file_extension,
                  :projects,
                  :present,
                  :alternative_iris,
                  :ontology_type_id,
                  :license_model_ids,
                  :formality_level_id,
                  :task_ids,
                  :project_ids

  validates_uniqueness_of :iri, :if => :iri_changed?
  validates_format_of :iri, :with => URI::regexp(Settings.allowed_iri_schemes)

  validates :documentation,
    allow_blank: true,
    format: { with: URI::regexp(Settings.allowed_iri_schemes) }

  validates_presence_of :basepath

  delegate :permission?, to: :repository

  strip_attributes :only => [:name, :iri]

  scope :list, includes(:logic).order('ontologies.state asc, ontologies.entities_count desc')

  scope :with_path, ->(path) do
    condition = <<-CONDITION
      ("ontology_versions"."file_extension" = :extname)
        OR (("ontology_versions"."file_extension" IS NULL)
          AND ("ontologies"."file_extension" = :extname))
    CONDITION

    with_basepath(File.basepath(path)).
      where(condition, extname: File.extname(path)).
      readonly(false)
  end

  scope :with_basepath, ->(path) do
    join = <<-JOIN
      LEFT JOIN "ontology_versions"
      ON "ontologies"."ontology_version_id" = "ontology_versions"."id"
    JOIN

    condition = <<-CONDITION
      ("ontology_versions"."basepath" = :path)
        OR (("ontology_versions"."basepath" IS NULL)
          AND ("ontologies"."basepath" = :path))
    CONDITION

    joins(join).where(condition, path: path).readonly(false)
  end

  scope :parents_first, order('(CASE WHEN ontologies.parent_id IS NULL THEN 1 ELSE 0 END) DESC, ontologies.parent_id asc')


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

  def is?(logic_name)
    self.logic ? (self.logic.name == logic_name) : false
  end

  def owl?
    self.is?('OWL') || self.is?('OWL2')
  end

  def symbols
    entities
  end

  def symbols_count
    entities_count
  end

  def to_s
    name? ? name : iri
  end

  # Title for links
  def title
    name? ? iri : nil
  end

  def self.find_with_iri(iri)
    ontology = self.find_by_iri(iri)
    if ontology.nil?
      ontology = AlternativeIri.find_by_iri(iri).try(:ontology)
    end

    ontology
  end

  def is_imported?
    import_links.present?
  end

  def is_imported_from_other_repository?
    import_links_from_other_repositories.present?
  end

  def imported_by
    import_links.map(&:source)
  end

  def destroy_with_parent(user)
    if parent
      repository.delete_file(parent.path, user, "Delete ontology #{parent}") do
        parent.destroy
      end
    else
      repository.delete_file(path, user, "Delete ontology #{self}") do
        destroy
      end
    end
  end

  def destroy
    # if repository destroying, then check if imported externally
    if is_imported? &&
         (!repository.is_destroying? || is_imported_from_other_repository?)
      raise Ontology::DeleteError
    end
    super
  end

  def imported_ontologies
    fetch_links_by_kind(self, 'import')
  end

  def contains_logic_translations?
    query, args = contains_logic_translations_query(self)
    pluck_select([query, *args], :logically_translated).size > 1
  end

  def direct_imported_ontologies
    ontology_ids = Link.where(target_id: self, kind: 'import').
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

  def current_version
    self.versions.current
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

  protected

  def import_links
    Link.where(source_id: self.id, kind: "import")
  end

  def import_links_from_other_repositories
    import_links.select { |l| l.target.repository != self.repository }
  end

end
