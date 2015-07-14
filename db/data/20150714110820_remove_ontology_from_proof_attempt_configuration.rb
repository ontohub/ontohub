class RemoveOntologyFromProofAttemptConfiguration < MigrationWithData
  def up
    ProofAttemptConfiguration.find_each do |pac|
      pac.send(:generate_locid)
      pac.save!
    end
  end

  def down
    ProofAttemptConfiguration.find_each do |pac|
      pac.send(:generate_locid)
      pac.save!
    end
  end
end
