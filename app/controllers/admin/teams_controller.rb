class Admin::TeamsController < ApplicationController
  
  before_filter :authenticate_admin!
  
  inherit_resources
  actions :index
  respond_to :json, :xml
  has_pagination
  
end
