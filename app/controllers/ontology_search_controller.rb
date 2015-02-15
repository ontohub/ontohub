class OntologySearchController < ApplicationController

  def search
    @search_response = paginate_for(search_response)
    render 'shared/_ontology_search'
  end

  def search_response
    @anded = []
    @ored = []
    @search_query = []
    search_in_repository
    search_with_params
    if in_repository? || params[:query].present?
      @search_response = Ontology.search(@search_query).records      
    else
      @search_response = Ontology.scoped
    end
    refine_search_response
    @search_response
  end

  def refine_search_response
    if params[:ontology_type].present?
      @search_response = @search_response.
        filter_by_ontology_type(params[:ontology_type])
    end

    if params[:project].present?
      @search_response = @search_response.filter_by_project(params[:project])
    end

    if params[:formality_level].present?
      @search_response = @search_response.
        filter_by_formality(params[:formality_level])
    end

    if params[:license].present?
      @search_response = @search_response.filter_by_license(params[:license])
    end

    if params[:task].present?
      @search_response = @search_response.filter_by_task(params[:task])
    end
    @search_response
  end

  def search_in_repository
    if in_repository?
      @anded << "repository_id: #{params[:repository_id]}"
    end
  end

  def search_with_params
    if params[:query].present? && in_repository?
      search_params = params[:query].split(' ')
      @anded << search_params.delete(search_params.first)
      @anded = @anded.join(' AND ')
      if search_params.present?
        @ored = search_params.join(' OR ')
        @search_query = @anded + ' AND (' + @ored + ')'
      end
      @search_query = @anded
    elsif params[:query].present? && !in_repository?
      @search_query = params[:query].split(' ').join(' OR ')
    end
  end

  def repository
    Repository.find_by_path(params[:repository_id])
  end
end
