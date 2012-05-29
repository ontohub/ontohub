class CreateEntitiesSentencesTable < ActiveRecord::Migration
  def change
    create_table :entities_sentences, :id => false do |t|
      t.references :sentence, :null => false
      t.references :entity, :null => false
      t.references :ontology_version, :null => false
    end

    add_index :entities_sentences, [:sentence_id, :entity_id], :unique => true
    add_index :entities_sentences, [:entity_id, :sentence_id]

    change_table :entities_sentences do |t|
      t.foreign_key :entities, :dependent => :delete
      t.foreign_key :sentences, :dependent => :delete
    end
  end
end
