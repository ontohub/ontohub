class RemoveSourceUrlFromOntologyVersions < ActiveRecord::Migration
  def change
    remove_column :ontology_versions, :source_url
  end
end
