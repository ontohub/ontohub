class AxiomsController < InheritedResources::Base
  
  belongs_to :ontology
  
  actions :index
  
end
