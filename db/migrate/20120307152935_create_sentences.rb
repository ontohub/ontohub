class CreateSentences < ActiveRecord::Migration
  def change
    create_table :sentences do |t|
      t.references :ontology, :null => false
      t.string :name, :null => false
      t.text :text, :null => false
      t.string :range
      t.boolean :is_definition, :null => false, :default => false
      t.boolean :is_axiom, :null => false, :default => false
      t.integer :comments_count, :null => false, :default => 0

      t.timestamps :null => false
    end

    change_table :sentences do |t|
      t.index [:ontology_id, :id], :unique => true
      t.index [:ontology_id, :name], :unique => true
      t.foreign_key :ontologies, :dependent => :delete
    end
  end
end
