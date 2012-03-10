# 
# Displays all teams of the current users and creates new ones.
# 
class TeamsController < InheritedResources::Base
  
  before_filter :authenticate_user!
  before_filter :check_team_admin!, :only => [:edit, :update, :destroy]
  
  def create
    build_resource.admin_user = current_user
    super
  end
  
  protected
  
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
