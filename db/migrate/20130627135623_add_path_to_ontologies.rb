class AddPathToOntologies < ActiveRecord::Migration
  def change
    # is null for child ontologies in the same file
    add_column :ontologies, :path, :string
    add_index :ontologies, [:repository_id, :path], unique: true
  end
end
