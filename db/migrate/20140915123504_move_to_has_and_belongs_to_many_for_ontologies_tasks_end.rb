class MoveToHasAndBelongsToManyForOntologiesTasksEnd < ActiveRecord::Migration
  def up
    execute('ALTER TABLE "ontologies" DROP COLUMN IF EXISTS "task_id";')
    execute('ALTER TABLE "tasks" DROP COLUMN IF EXISTS "ontology_id";')
  end

  def down
    add_column(:tasks, :ontology_id, :integer)
    add_column(:ontologies, :task_id, :integer)
  end
end
