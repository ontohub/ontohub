class CreateOntologies < ActiveRecord::Migration
  def change
    create_table :ontologies do |t|
      t.references :language
      t.references :current_version
      t.string :uri, :null => false
      t.string :state, :default => 'pending', :null => false
      t.string :name
      t.text :description
      
      t.integer :entities_count, :axioms_count
      t.integer :versions_count, :metadata_count, :comments_count, :null => false, :default => 0
      
      t.timestamps :null => false
    end

    change_table :ontologies do |t|
      t.index :uri, :unique => true
      t.index :state
      t.index :language_id
      t.index :current_version_id
      t.foreign_key :languages
      t.foreign_key :ontology_versions, :column => :current_version_id
    end
  end
end
