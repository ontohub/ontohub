class AddStateToProofAttemptsAndTheorems < MigrationWithData
  def up
    add_column :proof_attempts, :state, :string, default: 'pending', null: false
    add_column :proof_attempts, :state_updated_at, :datetime
    add_column :proof_attempts, :last_error, :text

    add_column :sentences, :state, :string, null: true # null for axioms
    add_column :sentences, :state_updated_at, :datetime
    add_column :sentences, :last_error, :text

    Theorem.find_each do |theorem|
      update_attributes!(theorem, state: 'pending')
    end
  end

  def down
    remove_column :proof_attempts, :state
    remove_column :proof_attempts, :state_updated_at
    remove_column :proof_attempts, :last_error

    remove_column :sentences, :state, :string
    remove_column :sentences, :state_updated_at
    remove_column :sentences, :last_error
  end
end
