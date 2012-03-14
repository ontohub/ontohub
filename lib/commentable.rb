module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments,
      :as        => :commentable,
      :dependent => :delete_all
  end
end
