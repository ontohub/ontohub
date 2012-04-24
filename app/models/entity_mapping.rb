class EntityMapping < ActiveRecord::Base
  belongs_to :source
  belongs_to :target
  belongs_to :link_version
end
