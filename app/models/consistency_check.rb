#
# A consistency check for a given ontology version.
#
class ConsistencyCheck < ActiveRecord::Base
  include Resourcable

  belongs_to :object
  belongs_to :method
  attr_accessible :object_status, :method_status
end
