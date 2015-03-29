class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.text :key
      t.references :user
      t.string :status

      t.timestamps
    end
    add_index :api_keys, :key, unique: true
    add_index :api_keys, [:user_id, :status]
    add_index :api_keys, :user_id
  end
end
