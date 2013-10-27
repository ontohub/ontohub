class ApplicationController < ActionController::Base

  protect_from_forgery
  ensure_security_headers
  
  include Pagination
  include PathHelpers
  include ApplicationHelper
  
  # CanCan Authorization
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end
 
  if defined? PG
    # A foreign key constraint exception from the database
    rescue_from PG::Error do |exception|
      message = exception.message
      if message.include?('foreign key constraint')
        logger.warn(message)
        # shorten the message
        message = message.match(/DETAIL: .+/).to_s
        
        redirect_to :back,
          flash: {error: "Whatever you tried to do - the server is unable to process your request because of a foreign key constraint. (#{message})" }
      else
        # anything else
        raise exception
      end
    end
  end


  protected
  
  def authenticate_admin!
    unless admin?
      flash[:error] = 'you need admin privileges for this action'
      redirect_to :root
    end
  end

  def after_sign_in_path_for(resource)
    request.referrer
  end

  def after_sign_out_path_for(resource)
    request.referrer
  end

end
