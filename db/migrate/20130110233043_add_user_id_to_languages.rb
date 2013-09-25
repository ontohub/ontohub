class AddUserIdToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :user_id, :integer, null: false, default: 1
    add_foreign_key :languages, :users
  end
end
