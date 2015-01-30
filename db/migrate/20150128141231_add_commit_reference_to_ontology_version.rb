class AddCommitReferenceToOntologyVersion < ActiveRecord::Migration
  def change
    add_column :ontology_versions, :commit_id, :integer
  end
end
