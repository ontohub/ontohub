class Admin::CategoriesController < InheritedResources::Base
  
  before_filter :authenticate_admin!
  
  actions :all
  respond_to :json, :xml

  has_pagination

  def create
    create! { admin_categories_path }
  end

  def update
    update! do |success, failure|
      success.html { redirect_to collection_path }
    end
  end

  def resource
    if params[:id]
      super
    else
      @category = Category.where(:ancestry => nil)
    end
  end
  
end
