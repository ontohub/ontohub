# 
# Ontology search endpoints for the GWT search code.
# 
class OntologySearchController < ApplicationController

  respond_to :json

  def keywords
    prefix = params[:prefix] || ''
    if in_repository?
      repository = Repository.find_by_path params[:repository_id]
      respond_with OntologySearch.new.make_repository_keyword_list_json(repository, prefix)
    else
      respond_with OntologySearch.new.make_global_keyword_list_json(prefix)
    end
  end

  def search
    keywords = params[:keywords] || []
    keywords = keywords.map { |keyword| JSON.parse(keyword) }
    page = params[:page] || "0"
    page = page.to_i
    if in_repository?
      repository = Repository.find_by_path params[:repository_id]
      respond_with OntologySearch.new.make_bean_list_json(repository, keywords, page)
    else
      respond_with OntologySearch.new.make_bean_list_json(nil, keywords, page)
    end
  end

  def filters_map    
    respond_with OntologySearch.new.make_filters_map_json
  end

end
