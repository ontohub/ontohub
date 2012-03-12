class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # CanCan Authorization
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  
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
