class SshAccess

  PERMISSIONS = %w{
    read
    write
  }

  PERMISSION_MAP = {
    everyone: %w{read},
    permission: {
      all: %w{write},
      owner: [],
      editor: []
    }
  }

  class << self

    def determine_permission(requested_permission, permission)
      if PERMISSION_MAP[:everyone].include?(requested_permission)
        return true
      elsif permission
        return true if PERMISSION_MAP[:permission][:all].
          include?(requested_permission)

        role = permission.role.to_sym
        allowed_permissions = PERMISSION_MAP[:permission][role]
        return allowed_permissions.include?(requested_permission)
      else
        return false
      end
    end

    def extract_permission_params(params, repository)
      key_field = params[:key_id].sub("key-", "")
      requested_permission = params[:permission]
      user = User.joins(:keys).
        where(keys: {id: key_field}).first
      permission = nil
      permission = repository.highest_permission(user) if user
      return [requested_permission, permission]
    end

  end

end
