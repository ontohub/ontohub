module Metadatable
  extend ActiveSupport::Concern

  included do
    has_many :metadata,
      :as        => :metadatable,
      :dependent => :delete_all
  end
end
