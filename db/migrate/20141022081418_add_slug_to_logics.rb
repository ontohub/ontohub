class AddSlugToLogics < ActiveRecord::Migration
  def change
    add_column :logics, :slug, :string
  end
end
