class RemovePathFromOntology < ActiveRecord::Migration
  def change
    remove_column :ontologies, :basepath
    remove_column :ontologies, :file_extension
  end
end
