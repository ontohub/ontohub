class MoveToHasAndBelongsToManyForOntologiesTasks < ActiveRecord::Migration
  def up
    Task.find_each do |task|
      if task.read_attribute(:ontology_id)
        task.ontologies << Ontology.find(task.read_attribute(:ontology_id))
        task.save!
      end
    end
  end

  def down
    Task.find_each do |task|
      if task.ontologies.any?
        task.ontology_id = task.ontologies.first.id
        task.save!
      end
    end
  end
end
