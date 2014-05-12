module Pagination
  extend ActiveSupport::Concern

  module ClassMethods
    def has_pagination
      has_scope :page, :default => 1
      has_scope :per, :as => :per_page
    end
  end

end
