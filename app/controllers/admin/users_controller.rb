class Admin::UsersController < ApplicationController
  
  before_filter :authenticate_admin!
  
  inherit_resources
  has_scope :email_search
  has_pagination
  
  with_role :admin
  
  def update
    update! do
      params[:back_url].blank? ? collection_url : params[:back_url]
    end
  end
  
end
