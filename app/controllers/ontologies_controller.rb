#
# Controller for ontologies
#
class OntologiesController < InheritedResources::Base

  include FilesHelper

  belongs_to :repository, finder: :find_by_path!
  respond_to :json, :xml
  has_pagination
  has_scope :search, :state
  actions :index, :show, :edit, :update, :destroy

  before_filter :check_write_permission, except: [:index, :show, :oops_state]
  before_filter :check_read_permissions

  def index
    if in_repository?
      @search_response = paginate_for(parent.ontologies)
      @count = end_of_association_chain.total_count
      render :index_repository
    else
      @search_response = paginate_for(Ontology.scoped)
      @count = resource_class.count
      render :index_global
    end
  end

  def new
    @ontology_version = build_resource.versions.build
    @c_vertices = Category.first.roots.first.children rescue []
  end

  def edit
    @ontology = resource
    @c_vertices = Category.first.roots.first.children rescue []
  end

  def update
    resource.category_ids = user_selected_categories
    params[:ontology].try(:except!, :iri)
    super
  end

  def create
    @version = build_resource.versions.first
    @version.user = current_user
    super
    resource.category_ids = user_selected_categories
  end

  def show
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
          default_kind = resource.symbols.groups_by_kind.first.kind
          redirect_to locid_for(resource, :symbols, kind: default_kind)
        else
          redirect_to locid_for(resource, :children)
        end
      end
      format.json do
        respond_with resource
      end
      format.text { send_download }
    end
  end

  def destroy
    if resource.is_imported?
      flash[:error] = "Can't delete #{Settings.OMS.with_indefinite_article}
      that is imported by another one."
      redirect_to resource_chain
    else
      resource.destroy_with_parent(current_user)
      destroy!
    end
  end

  def retry_failed
    scope = end_of_association_chain

    if id = params[:id]
      # retry a specific ontology
      scope = scope.where(id: id)
    end

    scope.retry_failed

    redirect_to (id ? [parent, scope.first!, :ontology_versions] : [parent, :ontologies])
  end

  def oops_state
    respond_to do |format|
      format.json do
        respond_with resource.current_version.try(:request)
      end
    end
  end


  protected

  def check_read_permissions
    unless params[:action] == 'index'
      authorize!(:show, Repository.find_by_path(params[:repository_id]))
    end
  end

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

  def build_categories_tree(vertex)
    @a ||= []
    vertex.children.each { |child| build_categories_tree(child) unless child.children.empty?; @a << child }
    @a
  end

  def user_selected_categories
    params[:category_ids].keys unless params[:category_ids].nil?
  end

  helper_method :repository
  def repository
    parent
  end

  private
  def send_download
    asset = version || resource
    render text: asset.file_in_repository.content,
           content_type: Mime::Type.lookup('application/force-download')
  end

  def version
    finder = OntologyVersionFinder.new(params[:reference], resource)
    @version ||= finder.find if params[:reference]
  end
end
