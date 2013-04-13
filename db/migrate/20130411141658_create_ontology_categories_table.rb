class CreateOntologyCategoriesTable < ActiveRecord::Migration
  def change
    create_table :ontology_categories do |t|
      t.references :ontology, :null => false
      t.integer :category_id
    end
  end

end
