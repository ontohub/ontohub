# 
# Permissions list administration of a team, only accessible by ontology owners
# 
class PermissionsController < PrivilegeList::Base
  
  belongs_to :ontology
  
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
