class RemoveNotNullConstraintOfObsoletField < ActiveRecord::Migration
  def up
    change_column :links, :ontology_id, :integer, :null => true
  end

  def down
  end
end
