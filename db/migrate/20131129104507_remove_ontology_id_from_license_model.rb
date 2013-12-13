class RemoveOntologyIdFromLicenseModel < ActiveRecord::Migration
  def up
    remove_column :license_models, :ontology_id
  end
end
