class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :name
      t.string :uri

      t.timestamps :null => false
    end
    change_table :languages do |t|
      t.index :name, :unique => true
    end
  end
end
