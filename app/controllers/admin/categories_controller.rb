class Admin::CategoriesController < InheritedResources::Base
  
  before_filter :authenticate_admin!
  
  # actions :all
  respond_to :json, :xml

  has_pagination
  
end
