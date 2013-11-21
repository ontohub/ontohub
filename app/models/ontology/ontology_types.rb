module Ontology::OntologyTypes
  extend ActiveSupport::Concern

  included do
    belongs_to :ontology_type
  end

end
