class AddStateUpdatedAt < ActiveRecord::Migration
  def change
    [:ontology_versions, :oops_requests, :repositories].each do |table|
      add_column table, :state_updated_at, :datetime
    end
  end
end
