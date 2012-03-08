class Ontology < ActiveRecord::Base
  include Metadatable

  include Ontology::Entities
  include Ontology::Axioms
  include Ontology::Import

  belongs_to :logic
  belongs_to :user
  has_many :versions, :class_name => 'OntologyVersion'

  attr_accessible :uri, :name, :description
  
  def to_s
    uri
  end
  
end
