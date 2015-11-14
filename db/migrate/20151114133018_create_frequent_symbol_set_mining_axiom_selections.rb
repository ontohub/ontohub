class CreateFrequentSymbolSetMiningAxiomSelections < ActiveRecord::Migration
  def change
    create_table :frequent_symbol_set_mining_axiom_selections do |t|
      t.integer :depth_limit
      t.integer :minimal_symbol_set_size
      t.float :minimum_support
      t.string :minimum_support_type
      t.integer :short_axiom_tolerance

      t.timestamps
    end
  end
end
