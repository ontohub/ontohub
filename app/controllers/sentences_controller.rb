# 
# Lists sentences of an ontology
# 
class SentencesController < InheritedResources::Base

  belongs_to :ontology

  actions :index
  respond_to :json, :xml
  has_pagination

  def index
    @content_kind = :ontologies
    super.index
  end
    
end
