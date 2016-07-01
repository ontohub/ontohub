class LocId < ActiveRecord::Base
  belongs_to :specific, polymorphic: true
  attr_accessible :specific, :specific_id, :specific_type
  attr_accessible :locid
end
