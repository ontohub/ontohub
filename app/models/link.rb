class Link < ActiveRecord::Base
  belongs_to :source
  belongs_to :target
end
