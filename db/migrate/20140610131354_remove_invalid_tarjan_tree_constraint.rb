class RemoveInvalidTarjanTreeConstraint < ActiveRecord::Migration
  def change
    change_table :entity_groups do |t|
      t.remove_index [:ontology_id, :name]
    end
  end
end
