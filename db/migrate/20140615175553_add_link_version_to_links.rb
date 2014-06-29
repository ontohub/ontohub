class AddLinkVersionToLinks < ActiveRecord::Migration
  def change
    add_column :links, :link_version_id, :integer

    add_index :links, :link_version_id
  end
end
