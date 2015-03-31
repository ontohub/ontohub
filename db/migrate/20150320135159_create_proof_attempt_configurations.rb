class CreateProofAttemptConfigurations < ActiveRecord::Migration
  def change
    create_table :proof_attempt_configurations do |t|
      t.integer :timeout, null: true
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
  end
end
