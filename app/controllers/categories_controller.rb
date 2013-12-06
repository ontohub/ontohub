class CategoriesController < InheritedResources::Base
  belongs_to :ontology, :optional => true
    def index
      if params[:ontology_id]
        @ontology = Ontology.find(params[:ontology_id])
        @categories = Kaminari.paginate_array(@ontology.categories).page(params[:page])
      else
        @c_vertices = []
        vert = Category.first
        if vert
          @c_vertices = vert.roots.first.children
        end
      end
    end
    
    def show
      @category = Category.find(params[:id])
      categories = [@category.id]
      @category.children.each do |cate|
        categories << cate.id
      end
      @ontologies = Ontology.find(:all, :joins => :categories, :conditions => "categories.id IN (#{categories *","})")
    end
    
end
