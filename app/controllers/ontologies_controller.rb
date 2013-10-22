# 
# Controller for ontologies
# 
class OntologiesController < InheritedResources::Base

  include RepositoryHelper

  belongs_to :repository, finder: :find_by_path!
  respond_to :json, :xml
  has_pagination
  has_scope :search
  actions :index, :show, :edit, :update

  before_filter :check_write_permission, :except => [:index, :show, :oops_state]

  def index
    if in_repository?
      @content_kind = :repositories
    else
      @content_kind = :ontologies
    end
    @search = nil
    #super do |format|
    #  format.html do
    #    @search = params[:search]
    #    @search = nil if @search.blank?
    #  end
    #end
  end

  def new
    @content_kind = ":ontologies"
    @ontology_version = build_resource.versions.build
  end

  def create
    @content_kind = :ontologies
    @version = build_resource.versions.first
    @version.user = current_user
    super
  end
  
  def show
    @content_kind = :ontologies
    @content_object = :ontology
    if !params[:repository_id]
      # redirect for legacy routing
      ontology = Ontology.find params[:id]
      redirect_to [ontology.repository, ontology]
      return
    end

    respond_to do |format|
      format.html do
        if !resource.distributed?
          redirect_to repository_ontology_entities_path(parent, resource,
                       :kind => resource.entities.groups_by_kind.first.kind)
        else
          redirect_to repository_ontology_children_path(parent, resource)
        end
      end
      format.json do
        respond_with resource
      end
    end
  end
  
  def oops_state
    @content_kind = :ontologies
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
