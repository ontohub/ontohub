# 
# Lists entities of an ontology
# 
class ChildrenController < InheritedResources::Base
  
  belongs_to :ontology

  actions :index
  respond_to :json, :xml

end
