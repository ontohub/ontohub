class AddProjectsToOntologies < ActiveRecord::Migration

  def change
    create_table :projects do |t|
      t.string :name, :null => false
      t.string :institution, :null => false
      t.string :homepage, :null => false
      t.string :description, :null => false
      t.string :contact, :null => false

      t.timestamps
    end

    change_table :projects do |t|
      t.index :name, :unique => true
    end

    change_table :ontologies do |t|
      t.integer :project_id
      t.index :project_id
      t.foreign_key :projects
    end

  end
end
