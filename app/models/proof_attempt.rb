class ProofAttempt < ActiveRecord::Base
  include ProofAttempt::Status

  belongs_to :theorem, foreign_key: 'sentence_id'

  attr_accessible :status, :prover, :prover_output, :tactic_script, :time_taken

  validates_presence_of :theorem
  validates_inclusion_of :status, in: STATUSES

  after_save :update_theorem_status

  def update_theorem_status
    theorem.update_proof_status(status)
  end
end
