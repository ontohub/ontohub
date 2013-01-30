class AddUniqueIndizes < ActiveRecord::Migration
  def up
    add_index :supports, [:language_id, :logic_id], :unique => true
    add_index :logic_adjoints, [:translation_id, :projection_id], :unique => true
    add_index :language_adjoints, [:translation_id, :projection_id], :unique => true


  end

  def down
  end
end
