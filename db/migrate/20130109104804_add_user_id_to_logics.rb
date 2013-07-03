class AddUserIdToLogics < ActiveRecord::Migration
  def change
    add_column :logics, :user_id, :integer, null: false, default: 1
    add_foreign_key :logics, :users
  end
end
