#
# Member list administration of a team, only accessible by team admins
#
class TeamUsersController < PrivilegeList::Base

  belongs_to :team

  protected

  def relation_list
    @relation_list ||= RelationList.new [parent, :team_users],
      :model       => TeamUser,
      :collection  => collection,
      :association => :user,
      :scope       => User
  end

  def authorize_parent
    authorize! :edit, parent
  end

end
