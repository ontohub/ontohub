class AddTasksToOntologies < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name, :null => false
      t.string :description

      t.timestamps
    end

    change_table :tasks do |t|
      t.index :name, :unique => true
    end

    change_table :ontologies do |t|
      t.integer :task_id
      t.index :task_id
      t.foreign_key :tasks
    end
  end
end
