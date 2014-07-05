class CreateBasicProofs < ActiveRecord::Migration
  def change
    create_table :basic_proofs do |t|
      t.string :prover
      t.text :proof
      t.references :logic_mapping
      t.references :sentence

      t.timestamps
    end
    add_index :basic_proofs, :logic_mapping_id
    add_index :basic_proofs, :sentence_id

    change_table :basic_proofs do |t|
      t.foreign_key :logic_mappings, :dependent => :delete
      t.foreign_key :sentences, :dependent => :delete
    end
  end
end
