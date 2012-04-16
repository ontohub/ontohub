class CreateLogics < ActiveRecord::Migration
  def change
    create_table :logics do |t|
      t.string :name, :null => false
      t.string :iri

      t.timestamps :null => false
    end

    change_table :logics do |t|
      t.index :name, :unique => true
    end
  end
end
