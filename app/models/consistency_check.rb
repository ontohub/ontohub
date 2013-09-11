#
# A check with a named consistency checker.
#
# Examples:
# * Hermit checkOwlOntologyForConsistency
# * FaCT++ checkOwlOntologyForConsistency
#
class ConsistencyCheck < ActiveRecord::Base
  include Resourcable

  belongs_to :checker
  belongs_to :object
  attr_accessible :result_status, :result_proof, :process_status, :priority_order

end
