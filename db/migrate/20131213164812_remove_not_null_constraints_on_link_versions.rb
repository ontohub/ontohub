class RemoveNotNullConstraintsOnLinkVersions < ActiveRecord::Migration
  def change
    change_column :link_versions, :source_id, :integer, :null => true
    change_column :link_versions, :target_id, :integer, :null => true
  end
end
