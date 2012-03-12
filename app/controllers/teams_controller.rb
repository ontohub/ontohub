# 
# Displays all teams of the current users and creates new ones.
# 
class TeamsController < InheritedResources::Base
  
  before_filter :authenticate_user!
  before_filter :check_team_admin!, :only => [:edit, :update, :destroy]
  
  def show
    team_users = resource.team_users.joins(:user).order(:name).all
    @permission_list = PermissionList.new [resource, :team_users],
      :model      => TeamUser,
      :collection => team_users,
      :editable   => team_admin?,
      :scope      => User
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
  
  def check_team_admin!
    unless team_admin?
      flash[:error] = "You are not admin of this team!"
      redirect_to resource_path
    end
  end
  
  # is the current user admin for the current team?
  helper_method :team_admin?
  def team_admin?
    @team_admin ||= resource.admin?(current_user)
  end
  
  def collection
    @team_users ||= current_user.team_users
  end

end
