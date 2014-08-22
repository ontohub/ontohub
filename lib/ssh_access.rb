class SSHAccess

  class Error < ::StandardError; end
  class InvalidAccessOnMirrorError < Error; end

  PERMISSIONS = %w(
    read
    write
  )

  PERMISSION_MAP = {
    everyone: {
      'public_r' => %w(read),
      'public_rw' => %w(read write),
      'private_r' => %w(),
      'private_rw' => %w(),
    },
    permission: {
      all: {
        'public_r' => %w(read),
        'public_rw' => %w(read write),
        'private_r' => %w(read),
        'private_rw' => %w(read write),
      },
      owner: %(read write),
      editor: %(read write),
    }
  }

  attr_accessor :requested_permission, :permission, :repository

  def self.determine_permission(requested_permission, permission, repository)
    new(requested_permission, permission, repository).allowed?
  end

  def self.extract_permission_params(params, repository)
    key_field = params[:key_id].sub("key-", "")
    requested_permission = params[:permission]
    user = User.joins(:keys).
      where(keys: {id: key_field}).first
    permission = nil
    permission = repository.highest_permission(user) if user
    [requested_permission, permission]
  end

  def initialize(requested_permission, permission, repository)
    self.requested_permission = requested_permission
    self.permission = permission
    self.repository = repository
  end

  def allowed?
    not_a_write_to_mirror_repository! &&
      (allowed_for_everyone? || allowed_for_permission?)
  end

  def write_to_mirror_repository?
    repository.mirror? && requested_permission == 'write'
  end

  def not_a_write_to_mirror_repository!
    raise InvalidAccessOnMirrorError if write_to_mirror_repository?
    true
  end

  def allowed_for_permission?
    permission.present? &&
      (included_in?(:permission, :all, repository, requested_permission) ||
      included_in_role?(permission.role.to_sym, requested_permission))
  end

  def allowed_for_everyone?
    included_in?(:everyone, repository, requested_permission)
  end

  protected

  def included_in?(*groups, repository, requested_permission)
    in_map = groups.reduce(PERMISSION_MAP) { |map, group| map[group] }
    !! in_map[repository.access].try(:include?, requested_permission)
  end

  def included_in_role?(role, requested_permission)
    !! PERMISSION_MAP[:permission][role].try(:include?, requested_permission)
  end

end
