class AddUniqueIndizes < ActiveRecord::Migration
  def up
    add_index :supports, [:language_id, :logic_id], :unique => true


  end

  def down
  end
end
