# 
# Managing users of a team, only accessible by team admins
# 
class TeamUsersController < PrivilegeList::Base
  
  before_filter :authenticate_user!
  before_filter :parent
  belongs_to :team
  
  protected
  
  def permission_list
    @permission_list ||= PermissionList.new [parent, :team_users],
      :model       => TeamUser,
      :collection  => collection,
      :association => :user,
      :scope       => User
  end
  
  def parent
    # only admins should administrate the given team
    @team ||= current_user.team_users.admin.find_by_team_id!(params[:team_id]).team
  end
  
end
