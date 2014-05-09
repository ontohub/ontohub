class Users::RegistrationsController < Devise::RegistrationsController
  
  rescue_from Permission::PowerVaccuumError, :with => :power_error
  
  protected
  
  def power_error(exception)
    redirect_to :edit_user_registration, :flash => {:error => exception.message}
  end
  
  def after_inactive_sign_up_path_for(resource)
    after_sign_up_path
  end
  
  def after_sign_up_path_for(resource)
    after_sign_up_path
  end
end