module Resourcable
  extend ActiveSupport::Concern

  included do
    has_many :resources,
      :as        => :resourcable,
      :dependent => :delete_all
  end
end
