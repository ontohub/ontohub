class RemoveNotNullUserConstraintFromLogics < ActiveRecord::Migration
  def change
    change_column :logics, :user_id, :integer, :null => true, default: nil
  end
end
