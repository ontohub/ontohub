class CreateTranslatedSentences < ActiveRecord::Migration
  def change
    create_table :translated_sentences do |t|
      t.text :translated_text, null: false
      t.references :audience
      t.references :ontology
      t.references :sentence
      t.references :entity_mapping
      t.timestamps

    end

    add_index :translated_sentences, :ontology_id
    add_index :translated_sentences, :audience_id
  end
end
