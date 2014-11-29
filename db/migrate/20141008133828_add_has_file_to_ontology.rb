class AddHasFileToOntology < ActiveRecord::Migration
  def change
    add_column :ontologies, :has_file, :boolean, default: true, null: false
  end
end
