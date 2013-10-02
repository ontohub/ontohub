class Admin::JobsController < ApplicationController

  before_filter :authenticate_admin!
  
  inherit_resources
  actions :index
  respond_to :json, :xml
  has_pagination

  def index()
    @content_kind = :jobs
  end
   
end
