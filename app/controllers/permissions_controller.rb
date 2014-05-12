#
# Permissions list administration of permissions for a repository
#
class PermissionsController < PrivilegeList::Base

  belongs_to :repository, finder: :find_by_path!

  protected

  def relation_list
    @relation_list ||= RelationList.new [parent, :permissions],
      :model       => Permission,
      :collection  => collection,
      :association => :subject,
      :scope       => [User, Team]
  end

  def authorize_parent
    authorize! :permissions, parent
  end

end
