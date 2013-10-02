class SshAccessController < InheritedResources::Base

  def index
    allowed = false
    key_id = params[:key_id]
    key_field = key_id.sub("key-", "")
    requested_permission = params[:permission]
    user = User.joins(:keys).
      where(keys: {id: key_field}).first
    repository = parent
    permission = user.permissions.
      where(item_id: repository.id,
            item_type: repository.class).first
    allowed = SshAccess.determine_permission(requested_permission, permission)
    render json: {allowed: allowed}
  end

end
