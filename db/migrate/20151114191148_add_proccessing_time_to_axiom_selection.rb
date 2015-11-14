class AddProccessingTimeToAxiomSelection < ActiveRecord::Migration
  def change
    add_column :axiom_selections, :processing_time, :integer, default: 0
  end
end
