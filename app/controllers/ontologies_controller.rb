# 
# Controller for ontologies
# 
class OntologiesController < InheritedResources::Base

  belongs_to :repository, finder: :find_by_path!
  respond_to :json, :xml
  has_pagination
  has_scope :search

  before_filter :check_write_permission, :except => [:index, :show, :oops_state]

  def index
    @content_kind = :ontologies
    @search = nil
    #super do |format|
    #  format.html do
    #    @search = params[:search]
    #    @search = nil if @search.blank?
    #  end
    #end
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
    if !params[:repository_id]
      # redirect for legacy routing
      ontology = Ontology.find params[:id]
      redirect_to [ontology.repository, ontology]
      return
    end

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
    @ontology ||= begin
      type  = (params[:ontology] || {}).delete(:type)
      clazz = type=='DistributedOntology' ? DistributedOntology : SingleOntology
      @ontology = clazz.new params[:ontology]
      @ontology.repository = parent
      @ontology
    end
  end

  def check_write_permission
    authorize! :write, parent
  end

end
