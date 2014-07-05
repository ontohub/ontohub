class RenameCVerticesToCategories < ActiveRecord::Migration
  def change
    rename_table :c_vertices, :categories
  end
end
