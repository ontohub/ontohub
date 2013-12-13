class RemovePrivateToRepositories < ActiveRecord::Migration
  def change
    remove_column :repositories, :private_flag
  end
end
