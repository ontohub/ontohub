class OntologySearchController < ApplicationController

  def search
    @search_response = paginate_for(search_response)
    render 'shared/_ontology_search'
  end

  def search_response
    in_repository = in_repository?
    @search_response ||= OntologySearch.new(params, in_repository).
      search_response
  end
end
