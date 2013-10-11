# 
# Permissions list administration of a team, only accessible by ontology owners
# 
class OntologySearchController < ApplicationController

  respond_to :json
 
  def keywords
    prefix = params[:prefix]
    if prefix.blank?
      prefix = ''
    end

    ontologySearch = OntologySearch.new()
    @keywordList = ontologySearch.makeKeywordListJson(prefix)
    respond_with(@keywordList)
  end

  def search
    keywords = params[:keywords]
    if keywords.blank?
      keywords = Array.new
    end

    ontologySearch = OntologySearch.new()
    @beanList = ontologySearch.makeBeanListJson(keywords)
    respond_with(@beanList)
  end
  
end
