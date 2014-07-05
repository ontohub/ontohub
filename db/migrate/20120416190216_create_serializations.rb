class CreateSerializations < ActiveRecord::Migration
  def change
    create_table :serializations do |t|
      t.string :name
      t.string :extension
      t.string :mimetype
      t.references :language

      t.timestamps
    end

    change_table :serializations do |t|
      t.index :language_id
      t.foreign_key :languages
    end
  end
end
