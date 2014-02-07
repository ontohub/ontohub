class CreateEEdges < ActiveRecord::Migration

  def change
    create_table :e_edges do |t|
      t.references :parent
      t.references :child

      t.timestamps
    end

    add_index :e_edges, :parent_id
    add_index :e_edges, :child_id
  end

end
