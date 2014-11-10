class CreateProofTrees < ActiveRecord::Migration
  def change
    create_table :proof_trees do |t|
      t.string :tree

      t.references :proof_status, null: false

      t.timestamps
    end
  end
end
