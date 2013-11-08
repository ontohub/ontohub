class CategoriesController < InheritedResources::Base
  belongs_to :ontology
    def index
      @ontology = Ontology.find(params[:ontology_id])
      @categories = @ontology.categories
    end
end
