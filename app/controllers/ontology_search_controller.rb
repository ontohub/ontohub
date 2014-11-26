class OntologySearchController < ApplicationController

  def search
    if params[:query].present?
      @search_response = Ontology.search(params[:query]).records
    else
      @search_response = Ontology.scoped
    end

    if params[:ontology_type].present?
      @search_response = @search_response.filter_by_ontology_type(params[:ontology_type])
    end

    if params[:project].present?
      @search_response = @search_response.filter_by_project(params[:project])
    end

    if params[:formality_level].present?
      @search_response = @search_response.filter_by_formality(params[:formality_level])
    end

    if params[:license].present?
      @search_response = @search_response.filter_by_license(params[:license])
    end

    if params[:task].present?
      @search_response = @search_response.filter_by_task(params[:task])
    end

    @search_response = paginate_for(@search_response)
    render 'shared/_ontology_search'
  end
end
