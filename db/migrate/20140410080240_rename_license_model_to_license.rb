class RenameLicenseModelToLicense < ActiveRecord::Migration
def change
      rename_table :license_models, :licenses
      rename_column :ontologies, :license_model_id, :license_id

      rename_table :license_models_ontologies, :licenses_ontologies
      rename_column :licenses_ontologies, :license_model_id, :license_id
  end
end
