class MoveToHasAndBelongsToManyForOntologiesTasksEnd < ActiveRecord::Migration
  def up
    remove_column(:ontologies, :task_id)
    remove_column(:tasks, :ontology_id)
  end

  def down
    add_column(:tasks, :ontology_id, :integer)
    add_column(:ontologies, :task_id, :integer)
  end
end
