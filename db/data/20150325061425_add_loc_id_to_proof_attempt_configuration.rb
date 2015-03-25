class AddLocIdToProofAttemptConfiguration < ActiveRecord::Migration
  def up
    ProofAttemptConfiguration.find_each do |pac|
      pac.ontology = pac.proof_attempts.first.theorem.ontology
      pac.send(:generate_number)
      pac.send(:generate_locid)
      pac.save!
    end
  end
end
