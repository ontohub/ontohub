class Api::V1::OntologyVersionsController < Api::V1::Base
  inherit_resources
  defaults collection_name: :versions, finder: :find_by_number!
  belongs_to :ontology

  actions :show
end
