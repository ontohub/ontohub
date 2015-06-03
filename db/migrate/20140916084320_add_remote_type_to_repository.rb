class AddRemoteTypeToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :remote_type, :string, null: true
  end
end
