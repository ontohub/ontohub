#
# Allow searching for entities
#
class EntitiesSearchController < ApplicationController

  def index
    @query      = params[:q]
    @max_groups = 100

    if @query.blank?
      @query = nil
    else
      @search = Entity.search_with_ontologies(@query, @max_groups)
      @group  = @search.group(:ontology_id_str)
      @groups = @group.groups
    end
  end

end
