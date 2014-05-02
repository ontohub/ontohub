class AddEntityGroupRefererenceToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :entity_group_id, :integer
  end
end
