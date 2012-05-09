class CreateLogics < ActiveRecord::Migration
  def change
    create_table :logics do |t|
      t.string :name, :null => false
      t.string :uri
      t.string :extension
      t.string :mimetype

      t.timestamps :null => false
    end

    change_table :logics do |t|
      t.index :name, :unique => true
    end
  end
end
