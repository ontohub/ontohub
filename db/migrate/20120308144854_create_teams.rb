class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name, :null => false
    end

    change_table :teams do |t|
      t.index :name, :unique => true
    end
  end
end
