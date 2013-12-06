class AddToolsToOntologies < ActiveRecord::Migration
  def change
    create_table :tools do |t|
      t.string :name, :null => false
      t.string :description
      t.string :url

      t.timestamps
    end

    change_table :tools do |t|
      t.index :name, :unique => true
    end

    change_table :ontologies do |t|
      t.integer :tool_id
      t.index :tool_id
      t.foreign_key :tools
    end
  end
end
