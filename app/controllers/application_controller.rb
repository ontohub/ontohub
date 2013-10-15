class ApplicationController < ActionController::Base
  protect_from_forgery
  ensure_security_headers
  
  include Pagination
  include PathHelpers
  
  # CanCan Authorization
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
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
          :flash => {:error => "Whatever you tried to do - the server is unable to process your request because of a foreign key constraint. (#{message})" }
      else
        # anything else
        raise exception
      end
    end
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

  helper_method :resource_chain
  def resource_chain
    return @resource_chain if @resource_chain

    if params[:logic_id]
      @resource_chain = []
      return @resource_chain      
    end

    if !params[:repository_id] && !(params[:controller] == 'repositories' && params[:id])
      @resource_chain = []
      return @resource_chain
    end

    @resource_chain = [ Repository.find_by_path!( controller_name=='repositories' ? params[:id] : params[:repository_id] )]
    
    if id = params[:commit_reference_id]
      @resource_chain << CommitReference.new(id)
    end

    if id = (controller_name=='ontologies' ? params[:id] : params[:ontology_id])
      @resource_chain << Ontology.find(id)
    end

    @resource_chain
  end
  
  def after_sign_in_path_for(resource)
    request.referrer
  end

  def after_sign_out_path_for(resource)
    request.referrer
  end

  helper_method :cover_visible?
  def cover_visible?
    params[:controller] == 'home' && !user_signed_in?
  end

  helper_method :context_pane_visible?
  def context_pane_visible?
    if params[:controller] == 'home'
      return true
    end
    if params[:action] != 'index'
      return false
    end
    if %w(search logics repositories).include? params[:controller]
      return true
    end
    if params[:controller] == 'ontologies' && !in_repository?
      return true
    end
    return false 
  end 

  helper_method :in_repository?
  def in_repository?
    params[:repository_id] || params[:controller] == 'repositories'
  end

end
