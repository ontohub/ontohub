class CreateOntologyCategoriesTable < ActiveRecord::Migration
  def change
    create_table :categories_ontologies do |t|
      t.references :ontology
      t.references :category
    end
  end

end
