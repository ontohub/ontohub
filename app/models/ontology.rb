class Ontology < ActiveRecord::Base
  
  include Commentable
  include Permissionable
  include Metadatable

  include Ontology::Entities
  include Ontology::Axioms
  include Ontology::Import
  include Ontology::States
  include Ontology::Versions

  belongs_to :logic

  attr_accessible :uri, :name, :description

  validates_presence_of :uri
  validates_uniqueness_of :uri, :if => :uri_changed?
  
  strip_attributes :only => [:name, :uri]
  
  scope :search, ->(query) { where "uri ILIKE :term OR name ILIKE :term", :term => "%" << query << "%" }
  
  def to_s
    uri
  end
end
