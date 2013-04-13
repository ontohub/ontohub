class AddCategoriesCountToOntologies < ActiveRecord::Migration
  def change
    change_table :ontologies do |t|
      t.integer :categories_count, :null => false, :default => 0
    end
  end
end
