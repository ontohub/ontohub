class AddImportedAtToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :imported_at, :datetime
  end
end
