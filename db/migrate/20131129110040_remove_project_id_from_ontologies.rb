class RemoveProjectIdFromOntologies < ActiveRecord::Migration
  def up
    remove_column :ontologies, :project_id
  end

  def down
    add_column :ontologies, :project_id, :string
  end
end
