class CreateStructuredProofs < ActiveRecord::Migration
  def change
    create_table :structured_proofs do |t|
      t.string :rule

      t.timestamps
    end
  end
end
