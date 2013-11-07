class AddDescriptionToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :description, :text
  end
end
