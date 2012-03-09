class CreateAxioms < ActiveRecord::Migration
  def change
    create_table :axioms do |t|
      t.references :ontology, :null => false
      t.string :name, :null => false
      t.string :text, :null => false
      t.string :range

      t.timestamps :null => false
    end

    change_table :axioms do |t|
      t.index [:ontology_id, :id], :unique => true
      t.index [:ontology_id, :name], :unique => true
      t.foreign_key :ontologies, :dependent => :delete
    end
  end
end
