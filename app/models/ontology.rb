class Ontology < ActiveRecord::Base
  include Metadatable

  include Ontology::Entities
  include Ontology::Axioms

  belongs_to :logic
  has_many :versions, :class_name => 'OntologyVersion'
end
