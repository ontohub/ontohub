class CreateTeamUsers < ActiveRecord::Migration
  def change
    create_table :team_users do |t|
      t.references :team
      t.references :user
      t.boolean :admin, :default => false, :null => false
    end

    change_table :team_users do |t|
      t.index [:team_id, :user_id]
      t.foreign_key :users, :dependent => :delete
      t.foreign_key :teams, :dependent => :delete
    end
  end
end
