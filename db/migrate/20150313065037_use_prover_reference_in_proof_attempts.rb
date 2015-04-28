class UseProverReferenceInProofAttempts < MigrationWithData
  def up
    add_column :proof_attempts, :prover_id, :integer

    ProofAttempt.find_each do |proof_attempt|
      attrs = select_attributes(proof_attempt, :prover)
      prover = Prover.where(name: attrs[:prover]).first_or_create!
      update_attributes!(proof_attempt, prover_id: prover.id)
    end

    remove_columns :proof_attempts, :prover
  end

  def down
    add_column :proof_attempts, :prover, :string

    prover = Prover.where(name: 'SPASS').first_or_create!
    ProofAttempt.find_each do |proof_attempt|
      pa_attrs = select_attributes(proof_attempt, :prover_id)
      prover = Prover.find(pa_attrs[:prover_id])
      prover_attrs = select_attributes(prover, :name)
      update_attributes!(proof_attempt, prover: prover_attrs[:name])
    end

    remove_column :proof_attempts, :prover_id
  end
end
