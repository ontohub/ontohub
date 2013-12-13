class CreateJoinTableLicenseModelOntology < ActiveRecord::Migration
  def change
    create_table :license_model_ontology, :id => false do |t|
      t.integer :license_model_id
      t.integer :ontology_id
    end
  end
end
