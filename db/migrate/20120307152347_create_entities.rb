
# globally replace "entity" with "symbol"

class CreateEntities < ActiveRecord::Migration
  def change
    create_table :entities do |t|
      t.references :ontology, :null => false
      t.string :kind
      t.text :text, :null => false
      t.string :name, :null => false
      t.string :iri
      t.string :range
      t.integer :comments_count, :null => false, :default => 0

      t.timestamps :null => false
    end

    change_table :entities do |t|
      t.index [:ontology_id, :id], :unique => true
      t.index [:ontology_id, :kind] # for grouping
      t.index [:ontology_id, :text], :length => { :text => 255 }, :unique => true # for searching
      t.foreign_key :ontologies, :dependent => :delete
    end
  end
end
