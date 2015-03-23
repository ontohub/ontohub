class AddLocIdToProofAttempt < ActiveRecord::Migration
  def up
    ProofAttempt.find_each do |proof_attempt|
      proof_attempt.generate_locid
      proof_attempt.save!
    end
  end
end
