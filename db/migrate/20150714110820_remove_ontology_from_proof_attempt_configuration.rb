class RemoveOntologyFromProofAttemptConfiguration < MigrationWithData
  def up
    remove_column :proof_attempt_configurations, :ontology_id
  end

  def down
    add_column :proof_attempt_configurations,
               :ontology_id, :integer

    ProofAttempt.find_each do |proof_attempt|
      pa_attrs = select_attributes(proof_attempt,
                                   :sentence_id, :proof_attempt_configuration_id)
      theorem = Theorem.find(pa_attrs[:sentence_id])
      theorem_attrs = select_attributes(theorem, :ontology_id)

      pac = ProofAttempt.find(pa_attrs[:proof_attempt_configuration_id])
      update_columns(pac, ontology_id: theorem_attrs[:ontology_id])
    end

    change_column :proof_attempt_configurations,
                  :ontology_id, :integer, null: false
  end
end
