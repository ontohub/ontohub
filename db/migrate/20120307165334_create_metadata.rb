class CreateMetadata < ActiveRecord::Migration
  def change
    create_table :metadata do |t|
      t.references :metadatable, :polymorphic => true
      t.string :key
      t.string :value

      t.timestamps
    end

    change_table :metadata do |t|
      t.index [:metadatable_id, :metadatable_type]
    end
  end
end
