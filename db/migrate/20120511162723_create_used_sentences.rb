class CreateUsedSentences < ActiveRecord::Migration
  def change
    create_table :used_sentences do |t|
      t.references :basic_proof
      t.references :sentence

      t.timestamps
    end
    add_index :used_sentences, :basic_proof_id
    add_index :used_sentences, :sentence_id

    change_table :used_sentences do |t|
      t.foreign_key :basic_proofs, :dependent => :delete
      t.foreign_key :sentences, :dependent => :delete
    end
  end

end
