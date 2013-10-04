class AddBasePathToOntology < ActiveRecord::Migration
  def change
    add_column :ontologies, :basepath, :string
  end
end
