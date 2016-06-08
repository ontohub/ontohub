class CreateLocIds < ActiveRecord::Migration
  def up
    create_table :loc_ids do |t|
      t.text :locid, null: false
      t.integer :specific_id, null: false
      t.string :specific_type, null: false

      t.timestamps
    end
    add_index :loc_ids, :locid, unique: true
  end
end
