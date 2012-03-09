class EntitiesController < InheritedResources::Base
  
  belongs_to :ontology
  actions :index
  has_scope :page, :default => 1
  
end
