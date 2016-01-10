class CreateLocIds < ActiveRecord::Migration
  def up
    create_table :loc_ids do |t|
      t.string :locid, null: false
      t.integer :assorted_object_id, null: false
      t.string :assorted_object_type, null: false

      t.timestamps
    end
    add_index :loc_ids, :locid, unique: true
  end
end
