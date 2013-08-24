class CreateCategoriesTable < ActiveRecord::Migration
 def change
   create_table :categories do |t|
     t.string :name, :null => false
     t.string :ancestry
     t.timestamps :null => false


   end
   
   add_index :categories, :ancestry 
   add_index :categories, [:name, :ancestry], :unique => true
 end
end
