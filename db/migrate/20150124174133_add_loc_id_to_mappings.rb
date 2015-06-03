class AddLocIdToMappings < ActiveRecord::Migration
  def change
    add_column :mappings, :locid, :text
  end
end
