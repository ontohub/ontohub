module Repository::Access

  extend ActiveSupport::Concern

  OPTIONS = %w[private public_r public_rw]

  included do
    scope :pub, where("access != 'private'")
    scope :accessible_by, ->(user) do
      if user
        where("access != 'private'
          OR id IN (SELECT item_id FROM permissions WHERE item_type = 'Repository' AND subject_type = 'User' AND subject_id = ?)
          OR id IN (SELECT item_id FROM permissions INNER JOIN team_users ON team_users.team_id = permissions.subject_id AND team_users.user_id = ?
            WHERE  item_type = 'Repository' AND subject_type = 'Team')", user, user)
      else
        pub
      end
    end

    validates :access,
      presence: true,
      inclusion: { in: Repository::Access::OPTIONS }
  end

  def is_private
    access == 'private'
  end

  def public_rw?
    access == 'public_rw'
  end
  
  private

  def clear_readers
    if access_changed? and access_was == 'private'
      permissions.where(role: 'reader').each { |p| p.destroy }
    end
  end

end
