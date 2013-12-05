class CategoriesController < InheritedResources::Base
  belongs_to :ontology
    def index
      @ontology = Ontology.find(params[:ontology_id])
      @categories = Kaminari.paginate_array(@ontology.categories).page(params[:page])
      
    end
end
