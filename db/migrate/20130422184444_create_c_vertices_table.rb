class CreateCVerticesTable < ActiveRecord::Migration
 def change
   create_table :c_vertices do |t|
     t.string :name, :null => false
     t.string :ordinal
     t.timestamps :null => false


   end

   create_table :c_edges do |t|
     t.references :parent, :null => false
     t.references :child,  :null => false
   end

   add_index :c_edges, [:parent_id, :child_id], :unique => true
 end
end
