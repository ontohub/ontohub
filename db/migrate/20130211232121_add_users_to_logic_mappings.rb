class AddUsersToLogicMappings < ActiveRecord::Migration
  def change
    add_column :logic_mappings, :user_id, :integer, null: false, default: 1
    add_foreign_key :logic_mappings, :users
  end
end
