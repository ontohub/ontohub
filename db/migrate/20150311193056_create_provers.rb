class CreateProvers < ActiveRecord::Migration
  def change
    create_table :provers do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :provers, :name, unique: true
  end
end
