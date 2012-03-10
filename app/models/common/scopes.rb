module Common::Scopes
  
  extend ActiveSupport::Concern
  
  included do
    
    # excludes the given ids
    scope :without_ids, ->(ids) {
      ids = ids.to_s.split(",") unless ids.is_a?(Array)
      where("id NOT IN (?)", ids)
    }
    
  end
  
end