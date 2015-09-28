class CreateSineSymbolAxiomTriggers < ActiveRecord::Migration
  def change
    create_table :sine_symbol_axiom_triggers do |t|
      t.references :axiom_selection
      t.references :symbol
      t.references :axiom
      t.float :tolerance

      t.timestamps
    end
    add_index :sine_symbol_axiom_triggers, :axiom_selection_id
    add_index :sine_symbol_axiom_triggers, :symbol_id
    add_index :sine_symbol_axiom_triggers, :axiom_id
    add_index :sine_symbol_axiom_triggers,
              [:axiom_selection_id, :symbol_id, :axiom_id], unique: true,
              name: 'sine_symbol_axiom_triggers_unique'

    # We only want to send queries like
    # SELECT axiom FROM sine_symbol_triggers WHERE symbol_id = 1 AND tolerance <= 1.5
    # Thus, we also add an index on the tolerance.
    add_index :sine_symbol_axiom_triggers, :tolerance
  end
end
