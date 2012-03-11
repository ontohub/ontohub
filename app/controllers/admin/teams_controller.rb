class Admin::TeamsController < ApplicationController
  
  before_filter :authenticate_admin!
  
  inherit_resources
  actions :index
  has_scope :page, :default => 1
  
end
