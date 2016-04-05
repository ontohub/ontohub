# This module is supposed to be included into other model classes to define the
# scopes :pub and :accessible_by
module AccessScopesForRepositoryAssociations
  extend ActiveSupport::Concern

  included do
    # access scopes
    scope :pub, -> do
      joins(:repository).
        # simulating scope: repository.active
        where('repositories.is_destroying = ?', false).
        where("repositories.access NOT LIKE 'private%'")
    end
    scope :accessible_by, ->(user) do
      if user
        joins(:repository).
          # simulating scope: repository.active
          where('repositories.is_destroying = ?', false).
          where(Repository::ACCESSIBLE_BY_SQL_QUERY, user, user)
      else
        pub
      end
    end
  end
end
