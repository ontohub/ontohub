class MoveToHasAndBelongsToManyForOntologiesTasks < ActiveRecord::Migration
  def up
    create_table(:ontologies_tasks, id: false) do |t|
      t.column(:ontology_id, :integer, null: false)
      t.column(:task_id, :integer, null: false)
    end

    add_index(:ontologies_tasks, [:ontology_id, :task_id], unique: true)
    add_foreign_key(:ontologies_tasks, :ontologies, column: 'ontology_id')
    add_foreign_key(:ontologies_tasks, :tasks, column: 'task_id')

    Task.find_each do |task|
      if task.read_attribute(:ontology_id)
        task.ontologies << Ontology.find(task.read_attribute(:ontology_id))
        task.save!
      end
    end

    remove_column(:ontologies, :task_id)
    remove_column(:tasks, :ontology_id)
  end

  def down
    add_column(:tasks, :ontology_id, :integer)
    add_column(:ontologies, :task_id, :integer)

    Task.find_each do |task|
      if task.ontologies.any?
        task.ontology_id = task.ontologies.first.id
        task.save!
      end
    end

    remove_foreign_key(:ontologies_tasks, name: 'ontologies_tasks_task_id_fk')
    remove_foreign_key(:ontologies_tasks, name: 'ontologies_tasks_ontology_id_fk')
    remove_index(:ontologies_tasks, column: [:ontology_id, :task_id])

    drop_table(:ontologies_tasks)
  end
end
