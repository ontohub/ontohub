class AddFileExtensionToOntology < ActiveRecord::Migration
  def change
    add_column :ontologies, :file_extension, :string
  end
end
