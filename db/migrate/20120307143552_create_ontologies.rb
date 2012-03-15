class CreateOntologies < ActiveRecord::Migration
  def change
    create_table :ontologies do |t|
      t.references :logic
      t.string :uri, :null => false
      t.string :state, :default => 'pending', :null => false
      t.string :name
      t.text :description
      
      t.integer :entities_count, :axioms_count
      t.integer :versions_count, :metadata_count, :comments_count, :null => false, :default => 0
      
      t.timestamps :null => false
    end

    change_table :ontologies do |t|
      t.index :uri, :unique => true
      t.index :state
      t.index :logic_id
      t.foreign_key :logics
    end
  end
end
