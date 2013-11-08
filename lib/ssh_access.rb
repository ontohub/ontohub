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

  end

end
