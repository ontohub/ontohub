module Permissionable
  extend ActiveSupport::Concern

  included do
    has_many :permissions, :as => :item

    after_create :add_permission, if: :create_permission?
  end
  
  def permissions_count
    permissions.count
  end
  
  def permission?(role, user)
    # Deny if user is nil
    return false unless user
    
    # Deny if user is of wrong type
    raise ArgumentError, "no user given" unless user.is_a? User
    
    # Allow any admin user.
    return true if user.admin? rescue nil

    # Retrieve direct user permissions.
    @perms = self.permissions.subject(user).all

    # Retrieve permissions through team.
    user.teams.each do |team|
      @perms << Permission.item(self).subject(team).all
    end

    # Deny if no permission is found.
    return false unless @perms

    # Allow if role matches any permission.
    @perms.flatten.each do |perm|
      # Requested role exists exactly as permission.
      return true if perm.role == role.to_s

      # editors have reader permissions.
      return true if perm.role == 'editor' and role == :reader

      # owners have reader and editor permissions.
      return true if perm.role == 'owner' and role == :reader
      return true if perm.role == 'owner' and role == :editor
    end

    # Deny otherwise.
    false
  end

  protected

  def create_permission?
    respond_to?(:user) && user
  end

  def add_permission
    permissions.create! :subject => self.user, :role => 'owner'
  end

end
