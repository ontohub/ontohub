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
    @keywordList
    respond_with(@keywordList)
  end
  
end
