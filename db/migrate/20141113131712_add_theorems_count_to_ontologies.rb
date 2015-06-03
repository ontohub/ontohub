class AddTheoremsCountToOntologies < ActiveRecord::Migration
  def change
    add_column :ontologies, :theorems_count, :integer, default: 0, null: false
  end
end
