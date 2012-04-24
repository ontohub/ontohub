class LinkVersion < ActiveRecord::Base
  belongs_to :link
  belongs_to :source
  belongs_to :target
  has_many :entity_mappings
end
