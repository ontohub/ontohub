# 
# Ontology search endpoints for the GWT search code.
# 
class OntologySearchController < ApplicationController

  respond_to :json

  def keywords
    prefix = params[:prefix] || ''
    respond_with OntologySearch.new.make_keyword_list_json(prefix)
  end

  def search
    keywords = params[:keywords] || []
    respond_with OntologySearch.new.make_bean_list_json(keywords)
  end
  
end
