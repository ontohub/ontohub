class CreateProofAttempts < ActiveRecord::Migration
  def change
    create_table :proof_attempts do |t|
      t.string :status
      t.string :prover
      t.text :tactic_script
      t.text :prover_output
      t.integer :time_taken

      t.references :sentence, null: false

      t.timestamps
    end
  end
end
