class CreateProofAttemptConfigurations < ActiveRecord::Migration
  def up
    ProofAttempt.find_each do |proof_attempt|
      config = ProofAttemptConfiguration.new
      config.save!
      proof_attempt.proof_attempt_configuration = config
      proof_attempt.save!
    end
  end
end
