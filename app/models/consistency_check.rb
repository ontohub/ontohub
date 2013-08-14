#
# A consistency check for a given ontology version.
#
class ConsistencyChecker < ActiveRecord::Base
  include Resourcable

  belongs_to :object
  belongs_to :method
  attr_accessible :object_status, :method_status
end
