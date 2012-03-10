# 
# Managing users of a team, only accessible by team admins
# 
class TeamUsersController < InheritedResources::Base
  
  before_filter :authenticate_user!
  belongs_to :team
  rescue_from Permission::PowerVaccuumError, :with => :power_error
  
  def create
    build_resource.save!
    respond_to do |format|
      format.html { render_resource }
    end
  end
  
  def update
    resource.update_attributes! params[:team_user]
    respond_to do |format|
      format.html { render_resource }
    end
  end
  
  def destroy
    resource.destroy
    head :ok
  end
  
  protected
  
  def render_resource
    render :partial => '/teams/user', :locals => {:user => resource, :show_admin_links => true}
  end
  
  def parent
    # only admins should administrate the given team
    @team ||= current_user.team_users.admin.find_by_team_id!(params[:team_id]).team
  end
  
  def power_error(exception)
    render :text => exception.message, :status => :unprocessable_entity
  end
  
end
