class IndexNameOfProofStatusesTable < ActiveRecord::Migration
  def change
    add_index :proof_statuses, :name, unique: true
  end
end
