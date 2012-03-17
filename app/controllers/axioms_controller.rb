# 
# Lists axioms of a ontology
# 
class AxiomsController < InheritedResources::Base
  
  belongs_to :ontology
  actions :index
  respond_to :json, :xml
  has_pagination
  
end
