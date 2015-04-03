class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.text :key
      t.references :user
      t.string :state

      t.timestamps
    end
    add_index :api_keys, :key, unique: true
    add_index :api_keys, [:user_id, :state]
    add_index :api_keys, :user_id
  end
end
