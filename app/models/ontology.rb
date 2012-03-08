class Ontology < ActiveRecord::Base
  include Metadatable

  include Ontology::Entities
  include Ontology::Axioms
  include Ontology::Import

  belongs_to :logic
  has_many :versions, :class_name => 'OntologyVersion'
end
