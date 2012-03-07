class Ontology < ActiveRecord::Base
  include Metadatable

  belongs_to :logic
  has_many :versions, :class_name => 'OntologyVersion'
end
