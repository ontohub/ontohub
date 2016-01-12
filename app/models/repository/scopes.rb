module Repository::Scopes
  extend ActiveSupport::Concern

  included do
    ACCESSIBLE_BY_SQL_QUERY = <<SQL
repositories.access NOT LIKE 'private%'
OR repositories.id IN (SELECT item_id
          FROM permissions
          WHERE item_type = 'Repository'
          AND subject_type = 'User' AND subject_id = ?)
OR repositories.id IN (SELECT item_id
          FROM permissions
          INNER JOIN team_users
          ON team_users.team_id = permissions.subject_id
          AND team_users.user_id = ?
          WHERE item_type = 'Repository'
          AND subject_type = 'Team')
SQL

    equal_scope(*%w(path state))

    scope :pub, -> { active.where("access NOT LIKE 'private%'") }
    scope :accessible_by, ->(user) do
      if user
        active.where(ACCESSIBLE_BY_SQL_QUERY, user, user)
      else
        pub
      end
    end

    scope :with_source, -> { where('source_type IS NOT null') }

    # Ready for pulling
    scope :outdated, -> do
      with_source.
        where('imported_at IS NULL or imported_at < ?',
          Repository::Importing::IMPORT_INTERVAL.ago).
        where(state: 'done')
    end
  end
end
