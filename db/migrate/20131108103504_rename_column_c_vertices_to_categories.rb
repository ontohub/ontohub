class RenameColumnCVerticesToCategories < ActiveRecord::Migration
rename_column :categories_ontologies, :c_vertex_id, :category_id
end
