class SshAccess

  PERMISSIONS = %w{
    read
    write
  }

  PERMISSION_MAP = {
    everyone: {
      'public_r' => %w{read},
      'public_rw' => %w{read write},
      'private_r' => %w{},
      'private_rw' => %w{},
    },
    permission: {
      all: {
        'public_r' => %w{},
        'public_rw' => %w{},
        'private_r' => %w{read},
        'private_rw' => %w{read write},
      },
      owner: [],
      editor: []
    }
  }

  class << self

    def determine_permission(requested_permission, permission, repository)
      if repository.public_rw?
        true
      elsif repository.public_r? && requested_permission == 'read'
        true
      elsif PERMISSION_MAP[:everyone][repository.access].include?(requested_permission)
        true
      elsif permission
        return true if PERMISSION_MAP[:permission][:all][repository.access].
          include?(requested_permission)

        role = permission.role.to_sym
        allowed_permissions = PERMISSION_MAP[:permission][role]
        allowed_permissions.include?(requested_permission)
      else
        false
      end
    end

    def extract_permission_params(params, repository)
      key_field = params[:key_id].sub("key-", "")
      requested_permission = params[:permission]
      user = User.joins(:keys).
        where(keys: {id: key_field}).first
      permission = nil
      permission = repository.highest_permission(user) if user
      [requested_permission, permission]
    end

  end

end
