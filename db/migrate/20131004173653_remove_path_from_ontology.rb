class RemovePathFromOntology < ActiveRecord::Migration
  def up
    remove_column :ontologies, :path
  end

  def down
    add_column :ontologies, :path, :string
  end
end
