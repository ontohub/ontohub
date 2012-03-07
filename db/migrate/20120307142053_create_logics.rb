class CreateLogics < ActiveRecord::Migration
  def change
    create_table :logics do |t|
      t.string :name
      t.string :uri

      t.timestamps
    end
  end
end
