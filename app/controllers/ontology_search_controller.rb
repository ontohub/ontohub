class OntologySearchController < ApplicationController

  def search
    if params[:query].present?
      @search_response = Ontology.search(params[:query]).records
    else
      @search_response = Ontology.scoped
    end

    end


    end



  end
end
