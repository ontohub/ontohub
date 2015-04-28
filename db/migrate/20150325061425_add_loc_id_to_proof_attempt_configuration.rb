class AddLocIdToProofAttemptConfiguration < ActiveRecord::Migration
  def change
    add_column :proof_attempt_configurations, :number, :integer
    add_column :proof_attempt_configurations, :ontology_id, :integer
    add_column :proof_attempt_configurations, :locid, :text
  end
end
