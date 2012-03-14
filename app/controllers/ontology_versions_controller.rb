# 
# Displays versions of a ontology
# 
class OntologyVersionsController < InheritedResources::Base
  
  defaults :collection_name => :versions
  actions :index
  belongs_to :ontology
  
end
