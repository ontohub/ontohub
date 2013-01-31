class AddNullConstraints < ActiveRecord::Migration
  def up
    change_column :supports, :updated_at, :datetime, :null => false
    change_column :supports, :created_at, :datetime, :null => false
    change_column :supports, :logic_id, :integer, :null => false
    change_column :supports, :language_id, :integer, :null => false
    change_column :serializations, :updated_at, :datetime, :null => false
    change_column :serializations, :created_at, :datetime, :null => false
    change_column :serializations, :language_id, :integer, :null => false
    change_column :basic_proofs, :updated_at, :datetime, :null => false
    change_column :basic_proofs, :created_at, :datetime, :null => false
    change_column :basic_proofs, :logic_mapping_id, :integer, :null => false
    change_column :basic_proofs, :sentence_id, :integer, :null => false
    change_column :structured_proofs, :updated_at, :datetime, :null => false
    change_column :structured_proofs, :created_at, :datetime, :null => false
    change_column :structured_proof_parts, :updated_at, :datetime, :null => false
    change_column :structured_proof_parts, :created_at, :datetime, :null => false
    change_column :structured_proof_parts, :structured_proof_id, :integer, :null => false
    change_column :structured_proof_parts, :sentence_id, :integer, :null => false
    change_column :structured_proof_parts, :link_version_id, :integer, :null => false
    change_column :used_sentences, :updated_at, :datetime, :null => false
    change_column :used_sentences, :created_at, :datetime, :null => false
    change_column :used_sentences, :basic_proof_id, :integer, :null => false
    change_column :used_sentences, :sentence_id, :integer, :null => false
    change_column :resources, :updated_at, :datetime, :null => false
    change_column :resources, :created_at, :datetime, :null => false
    change_column :resources, :resourcable_id, :integer, :null => false
    change_column :resources, :resourcable_type, :string, :null => false

  end

  def down
  end
end
