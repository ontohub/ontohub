class UseProverReferenceInProofAttempts < ActiveRecord::Migration
  def up
    remove_columns :proof_attempts, :prover
    add_column :proof_attempts, :prover_id, :integer
  end

  def down
    add_column :proof_attempts, :prover, :string
    remove_column :proof_attempts, :prover_id
  end
end
