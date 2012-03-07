module Metadatable
  extend ActiveSupport::Concern

  included do
    has_many :meta_datas, :as => :metadatable
  end
end
