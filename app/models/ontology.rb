class Ontology < ActiveRecord::Base
  include Permissionable
  include Metadatable

  include Ontology::Entities
  include Ontology::Axioms
  include Ontology::Import

  belongs_to :logic

  has_many :versions, :class_name => 'OntologyVersion'

  attr_accessible :uri, :name, :description, :logic_id
  
  def to_s
    uri
  end
end
