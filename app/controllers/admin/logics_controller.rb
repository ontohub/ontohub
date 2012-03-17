class Admin::LogicsController < ApplicationController
  
  before_filter :authenticate_admin!
  
  inherit_resources
  actions :index, :new, :create
  respond_to :json, :xml
  
  with_role :admin
  
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
