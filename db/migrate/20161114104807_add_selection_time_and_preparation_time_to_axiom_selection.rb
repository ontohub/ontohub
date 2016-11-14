class AddSelectionTimeAndPreparationTimeToAxiomSelection < ActiveRecord::Migration
  def change
    add_column :axiom_selections, :preparation_time, :integer, default: 0
    add_column :axiom_selections, :selection_time, :integer, default: 0
    remove_column :axiom_selections, :processing_time
  end
end
