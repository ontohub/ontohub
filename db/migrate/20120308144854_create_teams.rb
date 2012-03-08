class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.references :owner, :null => false
      t.string :name, :null => false
    end

    change_table :teams do |t|
      t.index :owner_id
      t.foreign_key :users, :column => :owner_id
    end
  end
end
