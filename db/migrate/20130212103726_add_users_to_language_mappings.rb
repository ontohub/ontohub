class AddUsersToLanguageMappings < ActiveRecord::Migration
  def change
    add_column :language_mappings, :user_id, :integer, null: false, default: 1
    add_foreign_key :language_mappings, :users
  end
end
