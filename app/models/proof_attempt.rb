class ProofAttempt < ActiveRecord::Base
  belongs_to :theorem, foreign_key: 'sentence_id'
  belongs_to :proof_status
  has_and_belongs_to_many :used_axioms,
    class_name: 'Sentence',
    join_table: 'used_axioms_proof_attempts'
  has_and_belongs_to_many :used_theorems,
    class_name: 'Theorem',
    association_foreign_key: 'sentence_id',
    join_table: 'used_axioms_proof_attempts'

  attr_accessible :prover, :prover_output, :tactic_script, :time_taken

  validates_presence_of :theorem

  after_save :update_theorem_status

  def used_sentences
    @used_sentences ||= used_axioms + used_theorems
  end

  def update_theorem_status
    theorem.update_proof_status(proof_status)
  end
end
