class OntologiesController < InheritedResources::Base
  
  actions :index, :show, :edit, :update, :destroy
  has_scope :page, :default => 1
  
end
