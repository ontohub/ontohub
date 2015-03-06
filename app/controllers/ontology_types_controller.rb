class OntologyTypesController < InheritedResources::Base
  respond_to :html
  respond_to :json, only: %i(show)
end
