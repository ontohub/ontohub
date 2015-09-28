class AddProvableToTheorems < ActiveRecord::Migration
  def change
    add_column :sentences, :provable, :boolean, default: false, null: false
  end
end
