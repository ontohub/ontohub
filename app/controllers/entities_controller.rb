# 
# Lists entities of an ontology
# 
class EntitiesController < InheritedResources::Base
  
  actions :index
  has_scope :kind
  has_pagination
  respond_to :json, :xml

  include OntologyVersionMember

end
