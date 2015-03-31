class ProofAttemptConfiguration < ActiveRecord::Base
  belongs_to :prover
  belongs_to :logic_mapping
  has_many :proof_attempts
  has_and_belongs_to_many :axioms,
                          class_name: 'Axiom',
                          association_foreign_key: 'sentence_id',
                          join_table: 'axioms_proof_attempt_configurations'
  has_and_belongs_to_many :goals,
                          class_name: 'Theorem',
                          association_foreign_key: 'sentence_id',
                          join_table: 'goals_proof_attempt_configurations'
  # timeout in seconds
  attr_accessible :timeout
end
