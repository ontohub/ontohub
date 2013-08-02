class AddExactnessLogicMappings < ActiveRecord::Migration
  def up
    add_column :logic_mappings, :exactness, :string, :null => false, :default => 'not_exact'
  end

  def down
    remove_column :logic_mappings, :exactness
  end
end
