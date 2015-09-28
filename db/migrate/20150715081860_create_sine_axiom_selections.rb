class CreateSineAxiomSelections < ActiveRecord::Migration
  def change
    create_table :sine_axiom_selections do |t|
      t.integer :commonness_threshold
      t.integer :depth_limit
      t.float :tolerance

      t.timestamps
    end
  end
end
