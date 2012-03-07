class CreateAxioms < ActiveRecord::Migration
  def change
    create_table :axioms do |t|
      t.string :text
      t.references :ontology

      t.timestamps
    end

    change_table :axioms do |t|
      t.index [:ontology_id, :id], :unique => true
      t.foreign_key :ontologies, :dependent => :delete
    end
  end
end
