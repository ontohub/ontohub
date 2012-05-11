class CreateBasicProofs < ActiveRecord::Migration
  def change
    create_table :basic_proofs do |t|
      t.string :prover
      t.string :proof
      t.references :translation

      t.timestamps
    end
    add_index :basic_proofs, :translation_id
  end
end
