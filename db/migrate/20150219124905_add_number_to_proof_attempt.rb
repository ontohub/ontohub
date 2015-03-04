class AddNumberToProofAttempt < ActiveRecord::Migration
  def change
    add_column :proof_attempts, :number, :integer, null: false
  end
end
