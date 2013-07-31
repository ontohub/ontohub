class AddConsistencyStatusToOntologyVersions < ActiveRecord::Migration
  def change
    add_column :ontology_versions, :consistency_status, :string, null: false, default: "unchecked"
  end
end
