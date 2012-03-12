# 
# Displays all teams of the current users and creates new ones.
# 
class TeamsController < InheritedResources::Base
  
  load_and_authorize_resource
  
  def show
    @team_users = resource.team_users.joins(:user).order(:name).all
  end
  
  def create
    build_resource.admin_user = current_user
    super
  end
  
  protected
  
  def permission_list
    raise NotImplementedError
    # you need to override this method with something like:
    # @permission_list ||= PermissionList.new ...
  end
  
  def collection
    @team_users ||= current_user.team_users
  end

end
