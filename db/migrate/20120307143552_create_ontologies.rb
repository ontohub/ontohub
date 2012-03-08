class CreateOntologies < ActiveRecord::Migration
  def change
    create_table :ontologies do |t|
      t.references :logic
      t.references :owner
      t.string :uri, :null => false
      t.string :state, :default => 'pending', :null => false
      t.string :name
      t.text :description

      t.timestamps :null => false
    end

    change_table :ontologies do |t|
      t.index :logic_id
      t.index :owner_id
      t.foreign_key :logics
      t.foreign_key :users, :column => :owner_id
    end
  end
end
