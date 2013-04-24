class CreateCategoriesOntologiesTable < ActiveRecord::Migration
  def change
    create_table :categories_ontologies, :id => false do |t|
      t.references :ontology, :null => false
      t.references :category, :null => false
    end

    add_index :categories_ontologies, [:category_id, :ontology_id], :unique => true
    add_index :categories_ontologies, [:ontology_id, :category_id]

    change_table :categories_ontologies do |t|
      t.foreign_key :categories, :dependent => :delete
      t.foreign_key :ontologies, :dependent => :delete
    end
  end

end
