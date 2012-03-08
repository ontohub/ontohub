class Admin::UsersController < ApplicationController
  
  before_filter :authenticate_admin!
  
  inherit_resources
  has_scope :email_search
  
  with_role :admin
  
end
