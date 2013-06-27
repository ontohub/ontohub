class AddPathToOntologies < ActiveRecord::Migration
  def change
    add_column :ontologies, :path, :string, null: false
    add_index :ontologies, [:repository_id, :path], unique: true
  end
end
