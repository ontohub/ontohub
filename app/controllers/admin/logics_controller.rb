class Admin::LogicsController < InheritedResources::Base
  
  before_filter :authenticate_admin!
  
  actions :index, :new, :create
  respond_to :json, :xml
  
  def create
    super do |success, failure|
      success.html { redirect_to collection_path }
    end
  end
  
  def update
    super do |success, failure|
      success.html { redirect_to collection_path }
    end
  end
  
end
