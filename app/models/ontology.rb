class Ontology < ActiveRecord::Base

  # Ontohub Library Includes  
  include Commentable
  include Permissionable
  include Metadatable

  # Ontology Model Includes
  include Ontology::Import
  include Ontology::States
  include Ontology::Versions

  belongs_to :language
  belongs_to :ontology_version

  attr_accessible :iri, :name, :description, :logic_id

  validates_presence_of :iri
  validates_uniqueness_of :iri, :if => :iri_changed?
  validates_format_of :iri, :with => URI::regexp(ALLOWED_URI_SCHEMAS)
  
  strip_attributes :only => [:name, :iri]

  scope :search, ->(query) { where "iri LIKE :term OR name LIKE :term", :term => "%" << query << "%" }

  def to_s
    name? ? name : iri
  end
  
  # title for links
  def title
    name? ? iri : nil
  end
  
end
