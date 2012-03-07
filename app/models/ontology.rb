class Ontology < ActiveRecord::Base
  belongs_to :logic
  has_many :versions, :class_name => 'OntologyVersion'
end
