class Ontology < ActiveRecord::Base
  include Metadatable

  include Ontology::Entities
  include Ontology::Axioms
  include Ontology::Import

  belongs_to :logic
  belongs_to :owner, :polymorphic => true

  has_many :versions, :class_name => 'OntologyVersion'
  has_many :permissions
  
  def to_s
    uri
  end
end
