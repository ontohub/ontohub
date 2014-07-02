#
# Permissions list administration of permissions for a repository
#
class PermissionsController < PrivilegeList::Base

  belongs_to :repository, finder: :find_by_path!

  def destroy
    destroy! do
      redirect_to(:back) and return
    end
  rescue Permission::PowerVaccuumError => e
    flash[:alert] = e.message
    redirect_to :back
  end

  def update
    super
  rescue ActiveRecord::RecordInvalid => e
    render text: e.message
  end

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
