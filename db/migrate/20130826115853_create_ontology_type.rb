class CreateOntologyType < ActiveRecord::Migration

  def change
    create_table :ontology_types do |t|
      t.string :name, :null => false
      t.string :description, :null => false
      t.string :documentation, :null => false
      t.timestamps :null => false
    end

    change_table :ontology_types do |t|
      t.index :name, :unique => true
    end

    change_table :ontologies do |t|
      t.integer :ontology_type_id
      t.index :ontology_type_id
      t.foreign_key :ontology_types
    end
  end

end
