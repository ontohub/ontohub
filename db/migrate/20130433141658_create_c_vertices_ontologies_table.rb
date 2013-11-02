class CreateCVerticesOntologiesTable < ActiveRecord::Migration
  def change
    create_table :c_vertices_ontologies do |t|
      t.references :ontology, :null => false
      t.references :c_vertex, :null => false
    end

    add_index :c_vertices_ontologies, [:ontology_id, :c_vertex_id]
    add_index :c_vertices_ontologies, [:c_vertex_id, :ontology_id], :unique => true

    change_table :c_vertices_ontologies do |t|
      t.foreign_key :c_vertices, :dependent => :delete
      t.foreign_key :ontologies, :dependent => :delete
    end
  end

end
