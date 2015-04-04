class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.integer :initial_eta
      t.integer :resource_id
      t.string :resource_type

      t.timestamps
    end
    add_index :actions, [:resource_id, :resource_type]
  end
end
