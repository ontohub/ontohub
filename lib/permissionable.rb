module Permissionable
  extend ActiveSupport::Concern

  included do
    has_many :permissions, :as => :permissionable
  end

  def permission?(role, user)
    # Deny if role is unknown or user is wrong object.
    return false unless [:owner, :editor].include? role
    return false unless user.is_a? User

    # Allow any admin user.
    return true if user.admin? rescue nil

    # Retrieve direct user permissions.
    @perms = Permission.find(self, user).all

    # Retrieve permissions through team.
    user.teams.each do |team|
      @perms << Permission.find(self, team)
    end

    # Deny if no permission is found.
    return false unless @perms

    # Allow if role matches any permission.
    @perms.flatten.each do |perm|
      return true if perm.role == role.to_s
      return true if perm.role == 'owner' and role == :editor
    end

    # Deny otherwise.
    false
  end
end
