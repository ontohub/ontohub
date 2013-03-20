class AddFragmentNameToEntity < ActiveRecord::Migration
  def change
    add_column :entities, :fragment_name, :string
  end
end
