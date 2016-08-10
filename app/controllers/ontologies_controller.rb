#
# Controller for ontologies
#
class OntologiesController < InheritedResources::Base

  include FilesHelper

  belongs_to :repository, finder: :find_by_path!
  has_pagination
  has_scope :search, :state

  actions :index, :show, :edit, :update, :destroy

  respond_to :html, except: %i(show)

  def index
    if in_repository?
      @search_response = paginate_for(parent.ontologies)
      @count = end_of_association_chain.accessible_by(current_user).total_count
      @repository_id = parent.id
      render :index_repository
    else
      @search_response = paginate_for(Ontology.scoped.
        accessible_by(current_user))
      @count = resource_class.accessible_by(current_user).count
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
    @version.pusher = current_user
    super
    resource.category_ids = user_selected_categories
  end

  def show
    @content_object = :ontology

    if !params[:repository_id]
      # redirect for legacy routing
      ontology = Ontology.find params[:id]
      redirect_to [ontology.repository, ontology, params_to_pass_on_redirect]
      return
    end

    respond_to do |format|
      format.html do
        if !resource.distributed?
          default_kind = resource.symbols.groups_by_kind.first.kind
          redirect_to url_for([resource, :symbols, params_to_pass_on_redirect.
                                 merge(kind: default_kind)])
        else
          redirect_to url_for([resource, :children, params_to_pass_on_redirect])
        end
      end
    end
  end

  def destroy
    if resource.can_be_deleted?
      resource.destroy_with_parent(current_user)
      destroy!
    else
      flash[:error] = t('ontology.delete_error',
                        oms_with_article: Settings.OMS.with_indefinite_article,
                        oms: Settings.OMS)
      redirect_to resource_chain
    end
  end

  def retry_failed
    scope = end_of_association_chain
    if id = params[:id]
      # retry a specific ontology
      scope = scope.where(id: id)
    end

    scope.retry_failed

    if id
      redirect_to url_for([resource, :ontology_versions])
    else
      redirect_to [parent, :ontologies]
    end
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
end
