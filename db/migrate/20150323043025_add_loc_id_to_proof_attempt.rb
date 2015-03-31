class AddLocIdToProofAttempt < ActiveRecord::Migration
  def change
    add_column :proof_attempts, :locid, :text
  end
end
