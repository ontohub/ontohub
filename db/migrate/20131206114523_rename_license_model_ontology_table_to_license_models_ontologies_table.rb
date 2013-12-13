class RenameLicenseModelOntologyTableToLicenseModelsOntologiesTable < ActiveRecord::Migration
  def change
      rename_table :license_model_ontology, :license_models_ontologies
  end 
end
