class AddFeaturedFlagToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :featured, :bool, default: false
  end
end
