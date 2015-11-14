class CreateSineFresymSymbolSets < ActiveRecord::Migration
  def change
    # model table
    create_table :sine_fresym_symbol_sets do |t|
      t.references :sine_fresym_axiom_selection
    end
    add_index :sine_fresym_symbol_sets, :sine_fresym_axiom_selection_id

    # association table
    create_table :sine_fresym_symbols do |t|
      t.references :sine_fresym_symbol_set
      t.references :symbol
    end
    add_index :sine_fresym_symbols, :sine_fresym_symbol_set_id
    add_index :sine_fresym_symbols, [:sine_fresym_symbol_set_id, :symbol_id],
               unique: true, name: 'sine_fresym_symbols_unique'
  end
end
