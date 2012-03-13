module Metadatable
  extend ActiveSupport::Concern

  included do
    has_many :metadata, :as => :metadatable
  end
end
