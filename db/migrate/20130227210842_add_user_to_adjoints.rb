class AddUserToAdjoints < ActiveRecord::Migration
  def change
    add_column :language_adjoints, :user_id, :integer, null: false, default: 1
    add_foreign_key :language_adjoints, :users
    add_column :logic_adjoints, :user_id, :integer, null: false, default: 1
    add_foreign_key :logic_adjoints, :users
  end
end
