class AlternativeIri < ActiveRecord::Base
  belongs_to :ontology

  attr_accessible :iri, :ontology
end
