class CreateEntities < ActiveRecord::Migration
  def change
    create_table :entities do |t|
      t.references :ontology, :null => false
      t.string :kind
      t.text :text, :null => false
      t.string :name, :null => false
      t.string :uri
      t.string :range

      t.timestamps :null => false
    end

    change_table :entities do |t|
      t.index [:ontology_id, :id], :unique => true
      t.index [:ontology_id, :text], :unique => true
      t.foreign_key :ontologies, :dependent => :delete
    end
  end
end
