class CreateUsedAxiomsProofAttemptsJoinTable < ActiveRecord::Migration
  def change
    create_table :used_axioms_proof_attempts, id: false do |t|
      t.integer :sentence_id
      t.integer :proof_attempt_id
    end

    add_index :used_axioms_proof_attempts, :sentence_id
    add_index :used_axioms_proof_attempts, :proof_attempt_id
  end
end
