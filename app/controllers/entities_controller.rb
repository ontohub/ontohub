# 
# Lists entities of an ontology
# 
class EntitiesController < InheritedResources::Base
  
  actions :index
  has_scope :kind
  has_pagination
  respond_to :json, :xml

  protected
  
  def ontology
    @ontology ||= Ontology.find(params[:ontology_id])
  end

  def version
    @version ||= ontology.versions.find_by_number!(params[:number])
  end

  def begin_of_association_chain
    version
  end

end
