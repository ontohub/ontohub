class IndexLocidSpecifics < ActiveRecord::Migration
  def up
    add_index :loc_ids, :specific_id
    add_index :loc_ids, :specific_type
  end

  def down
    remove_index :loc_ids, :specific_if
    remove_index :loc_ids, :specific_type
  end
end
