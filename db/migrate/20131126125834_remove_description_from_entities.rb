class RemoveDescriptionFromEntities < ActiveRecord::Migration
  def up
    remove_column :entities, :description
  end

  def down
    add_column :entities, :description, :string
  end
end
