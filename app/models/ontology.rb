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
  include Ontology::OntologyTypes
  include Ontology::Projects
  include Ontology::Tools
  include Ontology::Tasks
  include Ontology::LicenseModels
  include Ontology::FormalityLevels
  include Ontology::FileExtensions

  # Multiple Class Features
  include Aggregatable

  belongs_to :repository
  belongs_to :language
  belongs_to :logic, counter_cache: true
  has_many :source_links, class_name: 'Link', foreign_key: 'source_id', dependent: :destroy
  has_many :target_links, class_name: 'Link', foreign_key: 'target_id', dependent: :destroy
  attr_accessible :iri, :name, :description, :logic_id, :category_ids, :documentation, :acronym, :file_extension, :projects

  validates_uniqueness_of :iri, :if => :iri_changed?
  validates_format_of :iri, :with => URI::regexp(Settings.allowed_iri_schemes)

  validates :documentation,
    allow_blank: true,
    format: { with: URI::regexp(Settings.allowed_iri_schemes) }

  validates_presence_of :basepath

  delegate :permission?, to: :repository

  strip_attributes :only => [:name, :iri]

  scope :search, ->(query) { where "ontologies.iri #{connection.ilike_operator} :term OR name #{connection.ilike_operator} :term", :term => "%" << query << "%" }
  scope :list, includes(:logic).order('ontologies.state asc, ontologies.entities_count desc')

  def to_s
    name? ? name : iri
  end

  # title for links
  def title
    name? ? iri : nil
  end

  def symbols
    entities
  end

  def symbols_count
    entities_count
  end

  def path
    "#{basepath}#{file_extension}"
  end

end
