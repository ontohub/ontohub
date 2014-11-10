class CreateProofStatuses < ActiveRecord::Migration
  def change
    create_table :proof_statuses do |t|
      t.string :goal_name
      t.string :used_prover
      t.datetime :used_time

      t.references :goal_status
      t.references :proof_tree
      t.references :tactic_script

      t.timestamps
    end

    create_table :proof_statuses_sentences do |t|
      t.references :proof_status
      t.references :sentence
    end
  end
end
