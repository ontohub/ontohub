class Link < ActiveRecord::Base
  include Metadatable

  belongs_to :source
  belongs_to :target
end
