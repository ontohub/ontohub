class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.references :resourcable, :polymorphic => true
      t.string :kind
      t.string :uri

      t.timestamps
    end
    add_index :resources, :resourcable_id
  end
end
