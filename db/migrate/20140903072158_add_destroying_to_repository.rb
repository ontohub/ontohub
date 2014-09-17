class AddDestroyingToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :is_destroying, :boolean,
      default: false, null: false
  end
end
