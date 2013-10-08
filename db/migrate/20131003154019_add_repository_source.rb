class AddRepositorySource < ActiveRecord::Migration
  def change
    add_column :repositories, :source_type, :string, null: true, default: nil, limit: 5
    add_column :repositories, :source_address, :string, null: true, default: nil
  end
end
