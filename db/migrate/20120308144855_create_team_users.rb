class CreateTeamUsers < ActiveRecord::Migration
  def change
    create_table :team_users do |t|
      t.references :team, :null => false
      t.references :user, :null => false
      t.references :creator
      t.boolean :admin, :default => false, :null => false
    end

    change_table :team_users do |t|
      t.index [:team_id, :user_id], :unique => true
      t.foreign_key :teams, :dependent => :delete

      t.index :user_id
      t.foreign_key :users, :dependent => :delete

      t.index :creator_id
      t.foreign_key :users, :dependent => :nullify, :column => :creator_id
    end
  end
end
