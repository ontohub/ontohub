class ApplicationController < ActionController::Base
  protect_from_forgery
  
  protected
  
  def authenticate_admin!
    unless current_user.try(:admin?)
      flash[:error] = "you need admin privileges for this action"
      redirect_to :root
    end
  end
  
end
