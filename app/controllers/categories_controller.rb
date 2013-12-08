class CategoriesController < InheritedResources::Base
  belongs_to :ontology
  before_filter :check_read_permissions

  def index
    @ontology = Ontology.find(params[:ontology_id])
    @categories = Kaminari.paginate_array(@ontology.categories).page(params[:page])
  end

  protected

  def check_read_permissions
    authorize! :show, parent.repository
  end
end
