class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.references :subject, :polymorphic => true, :null => false
      t.references :item,    :polymorphic => true, :null => false
      t.references :creator
      t.string :role, :null => false, :default => 'editor'
      t.timestamps :null => false
    end

    change_table :permissions do |t|
      t.index [:item_id, :item_type, :subject_id, :subject_type],
        :name => 'index_permissions_on_item_and_subject',
        :unique => true
      t.index [:subject_id, :subject_type]

      t.index :creator_id
      t.foreign_key :users, :dependent => :nullify, :column => :creator_id
    end
  end
end
