class AddOopsRequestIdToOntologyVersion < ActiveRecord::Migration
  def change
    change_table :ontology_versions do |t|
      t.references :oops_request
    end
  end
end
