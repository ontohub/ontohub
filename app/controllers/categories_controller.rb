class CategoriesController < InheritedResources::Base
  
  actions :only => :show
  respond_to :json

  has_pagination

  def resource
    if params[:id]
      super
    else
      @category = Category.where(:ancestry => nil).first
    end
  end
  
end
