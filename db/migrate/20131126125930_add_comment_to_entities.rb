class AddCommentToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :comment, :text
  end
end
