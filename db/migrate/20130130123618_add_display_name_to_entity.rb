class AddDisplayNameToEntity < ActiveRecord::Migration
  def change
    add_column :entities, :display_name, :string
  end
end
