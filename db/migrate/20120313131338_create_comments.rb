class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :commentable, :polymorphic => true, :null => false
      t.references :user, :null => false
      t.text :text, :null => false
      t.timestamps :null => false
    end

    change_table :comments do |t|
      t.index [:commentable_id, :commentable_type, :id], :name => 'index_comments_on_commentable_and_id' # id for ordering
      t.index :user_id
      t.foreign_key :users
    end
  end
end
