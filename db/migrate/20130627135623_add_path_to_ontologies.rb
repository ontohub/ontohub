class AddPathToOntologies < ActiveRecord::Migration
  def change
    # is null for child ontologies in the same file
    add_column :ontologies, :path, :string
    add_index :ontologies, [:repository_id, :path], unique: true

    # allow null values
    change_column :ontologies, :iri, :string, null: true
  end
end
