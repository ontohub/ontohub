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
      allowed_for_everyone?(requested_permission, repository) ||
      allowed_for?(requested_permission, repository, through: permission)
    end

    def allowed_for?(requested_permission, repository, through: nil)
      through.present? &&
        (included_in?(:permission, :all, repository, requested_permission) ||
        included_in_role?(through.role.to_sym, requested_permission))
    end

    def allowed_for_everyone?(requested_permission, repository)
      included_in?(:everyone, repository, requested_permission)
    end

    def included_in?(*groups, repository, requested_permission)
      in_map = groups.reduce(PERMISSION_MAP) { |map, group| map[group] }
      in_map[repository.access].include?(requested_permission)
    end

    def included_in_role?(role, requested_permission)
      PERMISSION_MAP[:permission][role].include?(requested_permission)
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
