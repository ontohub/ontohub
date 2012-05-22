# 
# Lists sentences of an ontology
# 
class SentencesController < InheritedResources::Base

  actions :index
  respond_to :json, :xml
  has_pagination
    
  include OntologyVersionMember

end
