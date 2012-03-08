class EntitiesController < InheritedResources::Base
  
  belongs_to :ontology
  
  actions :index
  
end
