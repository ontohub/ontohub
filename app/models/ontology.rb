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

  attr_accessible :uri, :name, :description, :logic_id

  validates_presence_of :uri
  
  strip_attributes :only => [:name, :uri]
  
  def to_s
    uri
  end
end
