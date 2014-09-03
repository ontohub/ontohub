class AddParentOntologyVersionToOntologyVersion < ActiveRecord::Migration
  def change
    add_column :ontology_versions, :parent_id, :integer, default: nil
    add_foreign_key :ontology_versions, :ontology_versions, column: :parent_id
  end
end
