class AddIsDestroyingToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :is_destroying, :boolean, default: false
  end
end
