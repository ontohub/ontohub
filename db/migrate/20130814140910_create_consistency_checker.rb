class CreateConsistencyChecker < ActiveRecord::Migration
  def change
    create_table :consistency_checkers do |t|
      t.string :name, :null => false

      t.timestamps :null => false
    end    
    change_table :consistency_checkers do |t|
      t.index :name, :unique => true
    end
  end
end
