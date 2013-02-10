class RenameFragmentNameToDisplayNameInEntity < ActiveRecord::Migration
  def change
    rename_column :entities, :fragment_name, :display_name
  end
end
