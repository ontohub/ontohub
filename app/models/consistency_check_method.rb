#
# A method of a named consistency checker.
#
# Examples:
# * Hermit checkOwlOntologyForConsistency
# * FaCT++ checkOwlOntologyForConsistency
#
class ConsistencyCheckMethod < ActiveRecord::Base
  include Resourcable

  belongs_to :checker
  belongs_to :logic

  attr_accessible :priority_order
end
