class UseProverReferenceInProofAttempts < ActiveRecord::Migration
  def self.up
    prover = Prover.where(name: 'SPASS').first_or_create!
    ProofAttempt.find_each do |proof_attempt|
      proof_attempt.prover_id = prover.id
      proof_attempt.save!
    end
  end
end
