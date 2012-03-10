# 
# Managing users of a team, only accessible by team admins
# 
class TeamUsersController < InheritedResources::Base
  
  before_filter :authenticate_user!
  before_filter :check_remaining_admins, :only => [:destroy]
  belongs_to :team
  
  def create
    build_resource.save!
    respond_to do |format|
      format.html { render :partial => '/teams/user', :locals => {:user => resource, :show_admin_links => true} }
    end
  end
  
  def destroy
    resource.destroy
    head :ok
  end
  
  protected
  
  def parent
    # only admins should administrate the given team
    @team ||= current_user.team_users.admin.find_by_team_id!(params[:team_id]).team
  end
  
  # never allow to remove the last admin
  def check_remaining_admins
    if resource.admin? && end_of_association_chain.admin.count < 2
      render :text => 'What the hell ... nobody cares for your group if you remove the only one admin!', :status => :unprocessable_entity
    end
  end

end
