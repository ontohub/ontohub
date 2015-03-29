class ApiKeysController < InheritedResources::Base
  before_filter :authenticate_user!

  actions :create
  respond_to :html

  def create
    respond_with do |format|
      format.html do
        ApiKey.create_new_key!(current_user)
        redirect_to edit_user_registration_path(anchor: 'api_key'),
          notice: t(:successful_api_key_generation)
      end
    end
  end
end
