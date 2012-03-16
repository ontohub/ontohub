# 
# Permissions list administration of a team, only accessible by ontology owners
# 
class SearchController < ApplicationController
  
  def index
    @query      = query = params[:q]
    @max_groups = 100
    
    @search = Entity.search :include => [:ontology] do
      fulltext query do
        highlight :text
      end
      group :ontology_id_str do
        limit 10
      end
      paginate :page => params[:page], :per_page => @max_groups
    end
    
    @group  = @search.group(:ontology_id_str)
    @groups = @group.groups
  end
  
end
