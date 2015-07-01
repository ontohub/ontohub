class SineAxiomSelection < ActiveRecord::Base
  acts_as :axiom_selection

  attr_accessible :commonness_threshold, :depth_limit, :tolerance

  validates_numericality_of :commonness_threshold,
                            greater_than_or_equal_to: 0,
                            only_integer: true
  # Special case: The depth limit of -1 is considered to be infinite.
  validates_numericality_of :depth_limit,
                            greater_than_or_equal_to: -1,
                            only_integer: true
  validates_numericality_of :tolerance, greater_than_or_equal_to: 1

  delegate :mark_as_finished!, to: :axiom_selection
end
