
# globally replace "entity" with "symbol"

class CreateEntities < ActiveRecord::Migration
  def change
    create_table :entities do |t|
      t.references :ontology_version, :null => false
      t.string :kind
      t.text :text, :null => false
      t.string :name, :null => false
      t.string :iri
      t.string :range
      t.integer :comments_count, :null => false, :default => 0

      t.timestamps :null => false
    end

    change_table :entities do |t|
      t.index [:ontology_version_id, :id], :unique => true
      t.index [:ontology_version_id, :kind] # for grouping
      t.index [:ontology_version_id, :text], :length => { :text => 255 }, :unique => true # for searching
      t.foreign_key :ontology_versions, :dependent => :delete
    end
  end
end
