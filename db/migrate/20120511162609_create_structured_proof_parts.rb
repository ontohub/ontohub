class CreateStructuredProofParts < ActiveRecord::Migration
  def change
    create_table :structured_proof_parts do |t|
      t.references :structured_proof
      t.references :sentence
      t.references :link_version

      t.timestamps
    end
    add_index :structured_proof_parts, :structured_proof_id
    add_index :structured_proof_parts, :sentence_id
    add_index :structured_proof_parts, :link_version_id

    change_table :structured_proof_parts do |t|
      t.foreign_key :structured_proofs, :dependent => :delete
      t.foreign_key :sentences, :dependent => :delete
      t.foreign_key :link_versions, :dependent => :delete
    end
  end
end
