# 
# Permissions list administration of a team, only accessible by ontology owners
# 
class SearchController < ApplicationController
  
  DEFAULT_PAGE_LEN = 25
  
  def index
    @query = query = params[:q]
    
    @search = Entity.search :include => [:ontology] do
      fulltext query do
        highlight :text
      end
      group :ontology_id_str do
        limit 10
      end
      paginate :page => params[:page], :per_page => params[:per_page] || DEFAULT_PAGE_LEN
    end
    
    @group  = @search.group(:ontology_id_str)
    @groups = @group.groups
  end
  
end
