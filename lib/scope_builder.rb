module ScopeBuilder
  extend ActiveSupport::Concern

  included do
    # DEFAULT SCOPES --------------------------------------

    # excludes the given ids
    scope :without_ids, ->(ids){
      ids = ids.to_s.split(",") unless ids.is_a?(Array)
      where "id NOT IN (?)", ids
    }
  end

  module ClassMethods
    def equal_scope(*attributes)
      attributes.each do |attr|
        scope attr, ->(val){ where attr => val }
      end
    end
  end

end
