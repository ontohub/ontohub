class ProofStatus < ActiveRecord::Base
  has_one :goal_status
  has_one :proof_tree
  has_one :tactic_script
  has_and_belongs_to_many :sentences

  attr_accessible :goal_name, :used_prover, :used_time

  validates_presence_of :goal_name
  validates_presence_of :goal_status
  validates_presence_of :used_prover
  validates_presence_of :used_time
end
