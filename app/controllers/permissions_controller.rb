# 
# Managing users of a team, only accessible by team admins
# 
class PermissionsController < PrivilegeList::Base
  
  before_filter :authenticate_user!
  belongs_to :ontology
  
  protected
  
  def permission_list
    @permission_list ||= PermissionList.new [parent, :permissions],
      :model       => Permission,
      :polymorphic => 'subject',
      :collection  => collection.all,
      :editable    => true, # TODO
      :scope       => [User, Team]
  end
  
  def parent
    super #TODO check access
  end
  
end
