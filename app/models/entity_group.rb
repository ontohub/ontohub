class EntityGroup < ActiveRecord::Base
  attr_accessible :references
  has_many :entities
end
