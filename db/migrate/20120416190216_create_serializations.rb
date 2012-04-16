class CreateSerializations < ActiveRecord::Migration
  def change
    create_table :serializations do |t|
      t.string :name
      t.string :extension
      t.string :mimetype
      t.integer :language_id

      t.timestamps
    end
  end
end
