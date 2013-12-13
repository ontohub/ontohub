class AddOntologyIdToLicenseModel < ActiveRecord::Migration
  def change
    add_column :license_models, :ontology_id, :integer
  end
end
