class RemoveGoalsFromProofAttemptConfiguration < ActiveRecord::Migration
  def up
    drop_table :goals_proof_attempt_configurations
  end

  def down
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
