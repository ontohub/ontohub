class OntologySearchController < ApplicationController

  def search
    @search_response ||= paginate_for(OntologySearch.new(params, in_repository?,
      current_user).search_response)
    render 'shared/_ontology_search'
  end
end
