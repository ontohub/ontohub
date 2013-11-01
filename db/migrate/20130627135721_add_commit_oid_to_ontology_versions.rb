class AddCommitOidToOntologyVersions < ActiveRecord::Migration
  def change
    # SHA1 Hash
    add_column :ontology_versions, :commit_oid, :string, limit: 40
    add_index  :ontology_versions, :commit_oid

    # not needed any more
    remove_column :ontology_versions, :raw_file
    remove_column :ontology_versions, :xml_file
  end
end
