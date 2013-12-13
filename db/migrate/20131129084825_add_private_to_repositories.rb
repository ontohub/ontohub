class AddPrivateToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :private_flag, :boolean, default: false
  end
end
