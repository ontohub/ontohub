class ApplicationController < ActionController::Base
  protect_from_forgery
  
  protected
  
  helper_method :admin?
  def admin?
    current_user.try(:admin?)
  end
  
  def authenticate_admin!
    unless admin?
      flash[:error] = "you need admin privileges for this action"
      redirect_to :root
    end
  end
  
end
