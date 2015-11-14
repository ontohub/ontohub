class CreateSineFresymAxiomSelections < ActiveRecord::Migration
  def change
    create_table :sine_fresym_axiom_selections do |t|
      t.integer :commonness_threshold
      t.integer :depth_limit
      t.float :tolerance
      t.float :minimum_support
      t.string :minimum_support_type
      t.float :symbol_set_tolerance

      t.timestamps
    end
  end
end
