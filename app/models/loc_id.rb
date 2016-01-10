class LocId < ActiveRecord::Base
  belongs_to :assorted_object, polymorphic: true
  attr_accessible :assorted_object, :assorted_object_id, :assorted_object_type
  attr_accessible :locid
end
