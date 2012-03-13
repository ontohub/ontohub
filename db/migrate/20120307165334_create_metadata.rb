class CreateMetadata < ActiveRecord::Migration
  def change
    create_table :metadata do |t|
      t.references :metadatable, :polymorphic => true
      t.references :user
      t.string :key
      t.string :value

      t.timestamps
    end

    change_table :metadata do |t|
      t.index [:metadatable_id, :metadatable_type]
      t.index [:user_id]
      t.foreign_key :users
    end
  end
end
