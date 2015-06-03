class CreateHetsInstances < ActiveRecord::Migration
  def change
    create_table :hets_instances do |t|
      t.string :name
      t.text :uri, null: false, unique: :true
      t.text :version
      t.boolean :up, null: false, default: false

      t.timestamps
    end
  end
end
