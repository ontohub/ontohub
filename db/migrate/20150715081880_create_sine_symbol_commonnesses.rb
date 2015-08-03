class CreateSineSymbolCommonnesses < ActiveRecord::Migration
  def change
    create_table :sine_symbol_commonnesses do |t|
      t.references :axiom_selection
      t.references :symbol
      t.integer :commonness

      t.timestamps
    end
    add_index :sine_symbol_commonnesses, :axiom_selection_id
    add_index :sine_symbol_commonnesses, :symbol_id
    add_index :sine_symbol_commonnesses, [:axiom_selection_id, :symbol_id],
              unique: true,
              name: 'sine_symbol_commonnesses_unique'
  end
end
