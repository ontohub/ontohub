class TeamsController < InheritedResources::Base
  
  before_filter :authenticate_user!
  
  def create
    build_resource.admin_user = current_user
    super
  end
  
  protected
  
  def collection
    @team_users ||= current_user.team_users
  end

end
