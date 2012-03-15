# 
# Displays all teams of the current users and creates new ones.
# 
class TeamsController < InheritedResources::Base
  
  load_and_authorize_resource
  
  def show
    # users of current team
    @team_users = resource.team_users.joins(:user).order(:name).all
  end
  
  def create
    build_resource.admin_user = current_user
    super
  end
  
  protected
  
  def collection
    # show only teams of current user
    @team_users ||= current_user.team_users.joins(:team).order(:name).all
  end

end
