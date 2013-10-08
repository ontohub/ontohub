class AddBasePathToOntology < ActiveRecord::Migration
  def change
    remove_column :ontologies, :path
    add_column :ontologies, :basepath, :string, null: false
    add_column :ontologies, :file_extension, :string, limit: 20
    add_index  :ontologies, [:repository_id, :basepath]
  end
end
