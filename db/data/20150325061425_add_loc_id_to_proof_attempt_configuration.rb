class AddLocIdToProofAttemptConfiguration < ActiveRecord::Migration
  def up
    ProofAttemptConfiguration.find_each do |pac|
      pac.send(:generate_number)
      pac.send(:generate_locid)
      pac.save!
    end
  end
end
