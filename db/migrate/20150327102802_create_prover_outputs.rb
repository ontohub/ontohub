class CreateProverOutputs < ActiveRecord::Migration
  def up
    create_table :prover_outputs do |t|
      t.integer :proof_attempt_id, null: false
      t.text :content
      t.text :locid

      t.timestamps
    end

    ProofAttempt.find_each do |proof_attempt|
      prover_output = ProverOutput.new
      content =
        ProofAttempt.where(id: proof_attempt.id).pluck(:prover_output).first
      # The locid will be generated in the before_create hook
      prover_output.update_attributes!({proof_attempt_id: proof_attempt.id,
                                        content: content},
                                        without_protection: true)
    end

    remove_column :proof_attempts, :prover_output
  end

  def down
    add_column :proof_attempts, :prover_output, :text

    ProverOutput.find_each do |prover_output|
      prover_output.proof_attempt.
        update_attribute!(prover_output: ProverOutput.
          where(id: prover_output.id).pluck(:content).first)
    end

    drop_table :prover_outputs
  end
end
