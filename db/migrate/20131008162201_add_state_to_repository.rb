class AddStateToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :state, :string, null: false, default: 'done', limit: 30
    add_column :repositories, :last_error, :text
  end
end
