# 
# Lists sentences of an ontology
# 
class SentencesController < InheritedResources::Base

  belongs_to :ontology

  actions :index
  respond_to :json, :xml
  has_pagination

end
