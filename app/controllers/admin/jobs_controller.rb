class Admin::JobsController < InheritedResources::Base

  before_filter :authenticate_admin!
  
  actions :index
  respond_to :json, :xml
  has_pagination

end
