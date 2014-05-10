class RenameCVerticesOntologyTableToCategoriesOntologyTable < ActiveRecord::Migration
  def change
    rename_table :c_vertices_ontologies, :categories_ontologies
  end
end
