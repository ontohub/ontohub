class CategoriesController < InheritedResources::Base

  respond_to :json
  belongs_to :ontology, optional: true
  before_filter :check_read_permissions

  load_and_authorize_resource

  def index
    unless params[:ontology_id]
      @c_vertices = []
      if vert = Category.first
        @c_vertices = vert.roots.first.children
      end
    end

    super
  end

  def show
    @category = Category.find(params[:id])
    @ontologies = @category.related_ontologies
  end

  protected

  def check_read_permissions
    authorize! :show, parent.repository if parent.is_a? Ontology
  end

end
