class Admin::UsersController < InheritedResources::Base

  before_filter :authenticate_admin!

  respond_to :json, :xml
  has_scope :email_search
  has_pagination

  with_role :admin

  def update
    update! do |format|
      format.html do
        resource.skip_reconfirmation!
        resource.update_attributes({email: params["user"]["email"],
          name: params["user"]["name"],
          admin: params["user"]["admin"] == "1"}, without_protection: true)
        redirect_to(params[:back_url].blank? ? collection_url : params[:back_url])
      end
    end
  end

end
