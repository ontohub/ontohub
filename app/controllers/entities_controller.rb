# 
# Lists entities of an ontology
# 
class EntitiesController < InheritedResources::Base
  
  belongs_to :ontology
  actions :index
  has_scope :kind
  has_pagination
  respond_to :json, :xml
  
end
