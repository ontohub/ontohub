class RemoveStructuredProofs < ActiveRecord::Migration
  def up
    drop_table 'structured_proof_parts'
    drop_table 'structured_proofs'
  end

  def down
    create_table 'structured_proof_parts', :force => true do |t|
      t.integer  'structured_proof_id', :null => false
      t.integer  'sentence_id',         :null => false
      t.integer  'mapping_version_id',  :null => false
      t.datetime 'created_at',          :null => false
      t.datetime 'updated_at',          :null => false
    end

    add_index 'structured_proof_parts', ['mapping_version_id'], :name => 'index_structured_proof_parts_on_mapping_version_id'
    add_index 'structured_proof_parts', ['sentence_id'], :name => 'index_structured_proof_parts_on_sentence_id'
    add_index 'structured_proof_parts', ['structured_proof_id'], :name => 'index_structured_proof_parts_on_structured_proof_id'

    create_table 'structured_proofs', :force => true do |t|
      t.string   'rule'
      t.datetime 'created_at', :null => false
      t.datetime 'updated_at', :null => false
    end

    add_foreign_key 'structured_proof_parts', 'mapping_versions', name: 'structured_proof_parts_mapping_version_id_fk', dependent: :delete
    add_foreign_key 'structured_proof_parts', 'sentences', name: 'structured_proof_parts_sentence_id_fk', dependent: :delete
    add_foreign_key 'structured_proof_parts', 'structured_proofs', name: 'structured_proof_parts_structured_proof_id_fk', dependent: :delete
  end
end
