# 
# Controller for ontologies
# 
class OntologiesController < InheritedResources::Base

  respond_to :json, :xml
  has_pagination
  has_scope :search

  load_and_authorize_resource :except => [:index, :show]

  def index
    super do |format|
      format.html do
        @search = params[:search]
        @search = nil if @search.blank?
      end
    end
  end

  def new
    @ontology_version = build_resource.versions.build
  end

  def create
    @version = build_resource.versions.first
    @version.user = current_user
    super
  end
  
  def show
    respond_to do |format|
      format.html do
        redirect_to ontology_entities_path(resource, :kind => resource.entities.groups_by_kind.first.kind)
      end
      format.json do
        respond_with resource
      end
    end
  end
  
  def oops_state
    respond_to do |format|
      format.json do
        respond_with resource.versions.current.try(:request)
      end
    end
  end
  
  protected
  
  def build_resource
    return @ontology if @ontology
    
    type  = (params[:ontology] || {}).delete(:type)
    clazz = type=='DistributedOntology' ? DistributedOntology : SingleOntology
    @ontology = clazz.new params[:ontology]
  end

end
