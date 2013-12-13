class AddLabelToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :label, :string
  end
end
