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

  # Multiple Class Features
  include Aggregatable

  belongs_to :language
  belongs_to :logic, counter_cache: true
  belongs_to :ontology_type
  belongs_to :repository

  has_many :alternative_iris, dependent: :destroy
  has_many :source_links, class_name: 'Link', foreign_key: 'source_id', dependent: :destroy
  has_many :target_links, class_name: 'Link', foreign_key: 'target_id', dependent: :destroy

  has_and_belongs_to_many :formality_levels

  attr_accessible :iri, :name, :description, :acronym, :documentation,
                  :logic_id,
                  :category_ids,
                  :acronym,
                  :file_extension,
                  :projects,
                  :present,
                  :alternative_iris,
                  :ontology_type_id,
                  :formality_level_ids

  validates_uniqueness_of :iri, :if => :iri_changed?
  validates_format_of :iri, :with => URI::regexp(Settings.allowed_iri_schemes)

  validates :documentation,
    allow_blank: true,
    format: { with: URI::regexp(Settings.allowed_iri_schemes) }

  validates_presence_of :basepath

  delegate :permission?, to: :repository

  strip_attributes :only => [:name, :iri]

  scope :list, includes(:logic).order('ontologies.state asc, ontologies.entities_count desc')


  def generate_name(name)
    match = name.match(%r{
      \A
      < # angle brackets denote a custom IRI
      .+
      (?:/|\#)
        (?<filename>[^/]+) # Match filename after a slash/hash
      > # end of IRI
      \z
    }x)
    if match
      filename = match[:filename].sub(/\.[\w\d]+\z/, '')
      capitalized_name = filename.split(/([_ ])/).map(&:capitalize).join($1)
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

  def path
    "#{basepath}#{file_extension}"
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


  def self.find_by_file(file)
    s_find_by_file(file).first
  end

  def self.find_with_iri(iri)
    ontology = self.find_by_iri(iri)
    if ontology.nil?
      ontology = AlternativeIri.find_by_iri(iri).try(:ontology)
    end

    ontology
  end


  protected

  scope :s_find_by_file, ->(file) do
    where "ontologies.basepath = :basepath AND ontologies.file_extension = :file_extension AND ontologies.parent_id IS NULL",
      basepath: File.basepath(file),
      file_extension: File.extname(file)
  end

end
