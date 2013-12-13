class CategoriesController < InheritedResources::Base

  belongs_to :ontology, :optional => true

  def index
    if params[:ontology_id]
      @ontology = Ontology.find(params[:ontology_id])
      @categories = Kaminari.paginate_array(@ontology.categories).page(params[:page])
    else
      @c_vertices = []
      if vert = Category.first
        @c_vertices = vert.roots.first.children
      end
    end
  end
  
  def show
    @category = Category.find(params[:id])
    @ontologies = @category.related_ontologies
  end
    
end
