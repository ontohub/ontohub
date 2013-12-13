class AddIsPrivateToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :is_private, :boolean, default: false
  end
end
