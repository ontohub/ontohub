class RemoveBasicProofModel < ActiveRecord::Migration
  def up
    remove_foreign_key :used_sentences, name: 'used_sentences_basic_proof_id_fk'
    remove_foreign_key :used_sentences, name: 'used_sentences_sentence_id_fk'
    drop_table :basic_proofs
    drop_table :used_sentences
  end

  def down
    create_table 'basic_proofs', force: true do |t|
      t.string   'prover'
      t.text     'proof'
      t.integer  'logic_mapping_id', null: false
      t.integer  'sentence_id',      null: false
      t.datetime 'created_at',       null: false
      t.datetime 'updated_at',       null: false
    end

    add_index 'basic_proofs', ['logic_mapping_id'], name: 'index_basic_proofs_on_logic_mapping_id'
    add_index 'basic_proofs', ['sentence_id'], name: 'index_basic_proofs_on_sentence_id'

    create_table 'used_sentences', force: true do |t|
      t.integer  'basic_proof_id', null: false
      t.integer  'sentence_id',    null: false
      t.datetime 'created_at',     null: false
      t.datetime 'updated_at',     null: false
    end

    add_index 'used_sentences', ['basic_proof_id'], name: 'index_used_sentences_on_basic_proof_id'
    add_index 'used_sentences', ['sentence_id'], name: 'index_used_sentences_on_sentence_id'

    add_foreign_key 'used_sentences', 'basic_proofs', name: 'used_sentences_basic_proof_id_fk', dependent: :delete
    add_foreign_key 'used_sentences', 'sentences', name: 'used_sentences_sentence_id_fk', dependent: :delete
  end
end
