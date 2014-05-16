class CreateOntologies < ActiveRecord::Migration
  def change
    create_table :ontologies do |t|
      t.string :type, null: false, limit: 50, default: 'SingleOntology'
      t.references :parent
      t.references :language
      t.references :logic
      t.references :ontology_version
      t.string :iri, :null => false
      t.string :state, :default => 'pending', :null => false
      t.string :name
      t.text :description
      t.boolean :auxiliary, :default => false

      t.integer :entities_count, :sentences_count
      t.integer :versions_count, :metadata_count, :comments_count, :null => false, :default => 0

      t.timestamps :null => false
    end

    change_table :ontologies do |t|
      t.index :type
      t.index :iri, :unique => true
      t.index :state
      t.index :language_id
      t.index :logic_id
      t.foreign_key :ontologies, column: :parent_id
      t.foreign_key :logics
      t.foreign_key :languages
    end
  end
end
