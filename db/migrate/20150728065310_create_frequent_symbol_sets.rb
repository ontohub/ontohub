class CreateFrequentSymbolSets < ActiveRecord::Migration
  def change
    # model table
    create_table :frequent_symbol_sets do |t|
      t.references :axiom_selection
    end
    add_index :frequent_symbol_sets, :axiom_selection_id

    # association table
    create_table :frequent_symbols do |t|
      t.references :frequent_symbol_set
      t.references :symbol
    end
    add_index :frequent_symbols, :frequent_symbol_set_id
    add_index :frequent_symbols, [:frequent_symbol_set_id, :symbol_id],
               unique: true, name: 'frequent_symbols_unique'
  end
end
