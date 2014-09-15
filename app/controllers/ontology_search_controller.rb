class OntologySearchController < ApplicationController

  def search
    if params[:query].present?
      @search_response = Ontology.search(params[:query]).records
    else
      @search_response = Ontology.scoped
    end

    unless params[:ontology_type].empty?
      @search_response = @search_response.filter_by_ontology_type(params[:ontology_type])
    end

    unless params[:project].empty?
      @search_response = @search_response.filter_by_project(params[:project])
    end

    unless params[:formality_level].empty?
      @search_response = @search_response.filter_by_formality(params[:formality_level])
    end

    unless params[:license].empty?
      @search_response = @search_response.filter_by_license(params[:license])
    end

    unless params[:task].empty?
      @search_response = @search_response.filter_by_task(params[:task])
    end

    @search_response = paginate_for(@search_response)
    render "shared/_ontology_search"
  end

end
