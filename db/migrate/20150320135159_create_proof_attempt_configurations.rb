class CreateProofAttemptConfigurations < MigrationWithData
  def up
    create_table :proof_attempt_configurations do |t|
      t.integer :timeout, null: true
      t.references :ontology
      t.references :prover, null: true
      t.references :logic_mapping, null: true

      t.timestamps
    end

    add_column :proof_attempts, :proof_attempt_configuration_id, :integer

    create_table :axioms_proof_attempt_configurations, id: false do |t|
      t.integer :sentence_id
      t.integer :proof_attempt_configuration_id
    end
    add_index :axioms_proof_attempt_configurations, :sentence_id
    add_index :axioms_proof_attempt_configurations, :proof_attempt_configuration_id,
              # We need to supply a custom name because the generated name is
              # too long for PostgreSQL
              name: 'index_axioms_pacs_on_proof_attempt_configuration_id'

    create_table :goals_proof_attempt_configurations, id: false do |t|
      t.integer :sentence_id
      t.integer :proof_attempt_configuration_id
    end
    add_index :goals_proof_attempt_configurations, :sentence_id
    add_index :goals_proof_attempt_configurations, :proof_attempt_configuration_id,
              # We need to supply a custom name because the generated name is
              # too long for PostgreSQL
              name: 'index_goals_pacs_on_proof_attempt_configuration_id'


    ProofAttempt.find_each do |proof_attempt|
      config = ProofAttemptConfiguration.new
      create_unsafe(config)

      pa_attrs = select_attributes(proof_attempt, :sentence_id)
      theorem = Theorem.find(pa_attrs[:sentence_id])
      theorem_attrs = select_attributes(theorem, :ontology_id)

      update_columns(config, ontology_id: theorem_attrs[:ontology_id])

      update_attributes!(proof_attempt,
                         proof_attempt_configuration_id: config.id)
    end

    change_column :proof_attempt_configurations,
                  :ontology_id, :integer, null: false
  end

  def down
    drop_table :proof_attempt_configurations
    remove_column :proof_attempts, :proof_attempt_configuration_id

    drop_table :axioms_proof_attempt_configurations
    drop_table :goals_proof_attempt_configurations
  end
end
