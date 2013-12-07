class AddOntologyIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :ontology_id, :integer
  end
end
