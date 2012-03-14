class EntitiesController < InheritedResources::Base
  
  belongs_to :ontology
  actions :index
  has_scope :kind
  has_pagination
  
end
