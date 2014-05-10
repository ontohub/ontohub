class RemoveLinkVersionFromEntityMapping < ActiveRecord::Migration
  def up
    remove_column :entity_mappings, :link_version_id
    add_column :entity_mappings, :link_id, :integer, :null => false
  end

  def down
  end
end
