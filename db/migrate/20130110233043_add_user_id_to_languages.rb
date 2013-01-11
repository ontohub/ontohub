class AddUserIdToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :user_id, :integer
    add_foreign_key :languages, :users
  end
end
