class Users::ConfirmationsController < Devise::ConfirmationsController
  protected
  
  def after_resending_confirmation_instructions_path_for(resource_name)
    url_for [:edit, :user, :registration] if is_navigational_format?
  end
end
