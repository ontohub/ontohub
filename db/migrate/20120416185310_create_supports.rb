class CreateSupports < ActiveRecord::Migration
  def change
    create_table :supports do |t|
      t.integer :language_id
      t.integer :logic_id

      t.timestamps
    end
  end
end
