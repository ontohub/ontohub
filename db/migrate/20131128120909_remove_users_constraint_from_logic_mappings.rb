class RemoveUsersConstraintFromLogicMappings < ActiveRecord::Migration
  def change
    remove_foreign_key :logic_mappings, :users
  end
end
