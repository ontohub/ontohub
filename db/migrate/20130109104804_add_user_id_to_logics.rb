class AddUserIdToLogics < ActiveRecord::Migration
  def change
    add_column :logics, :user_id, :integer
    add_foreign_key :logics, :users
  end
end
