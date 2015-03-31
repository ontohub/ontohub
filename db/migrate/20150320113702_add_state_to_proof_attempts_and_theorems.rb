class AddStateToProofAttemptsAndTheorems < ActiveRecord::Migration
  def change
    add_column :proof_attempts, :state, :string, default: 'pending', null: false
    add_column :proof_attempts, :state_updated_at, :datetime
    add_column :proof_attempts, :last_error, :text

    add_column :sentences, :state, :string, null: true # null for axioms
    add_column :sentences, :state_updated_at, :datetime
    add_column :sentences, :last_error, :text
  end
end
