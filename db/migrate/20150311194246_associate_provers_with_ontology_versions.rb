class AssociateProversWithOntologyVersions < ActiveRecord::Migration
  def change
    create_table :ontology_versions_provers, id: false do |t|
      t.references :ontology_version, null: false
      t.references :prover, null: false
    end
  end
end
