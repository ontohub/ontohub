# 
# Lists entities of an ontology
# 
class EntitiesController < InheritedResources::Base
  
  belongs_to :ontology

  actions :index
  has_scope :kind
  has_pagination
  respond_to :json, :xml

  def index
    index! do |format|
      format.html do
        unless collection.blank?
          first_entity = collection.first
          @show_name_column = !(first_entity.display_name or first_entity.text.include? first_entity.name)
        end
      end
    end
  end
end
