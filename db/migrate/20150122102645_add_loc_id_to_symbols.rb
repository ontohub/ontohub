class AddLocIdToSymbols < ActiveRecord::Migration
  def change
    add_column :symbols, :locid, :text
  end
end
