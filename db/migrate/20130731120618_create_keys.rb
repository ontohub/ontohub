class CreateKeys < ActiveRecord::Migration
  def change
    create_table :keys do |t|
      t.references :user, null: false
      t.text   :key,         null: false
      t.string :name,        null: false, limit: 50
      t.string :fingerprint, null: false, limit: 32
      t.timestamps null: false
    end

    change_table :keys do |t|
      t.index       :user_id
      t.foreign_key :users, :dependent => :delete
      t.index       :fingerprint, unique: true
    end
  end
end
