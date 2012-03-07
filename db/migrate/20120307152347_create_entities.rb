class CreateEntities < ActiveRecord::Migration
  def change
    create_table :entities do |t|
      t.string :kind
      t.string :text, :null => false
      t.string :name, :null => false
      t.string :uri
      t.references :ontology

      t.timestamps
    end

    change_table :entities do |t|
      t.index [:ontology_id, :id], :unique => true
      t.foreign_key :ontologies, :dependent => :delete
    end
  end
end
