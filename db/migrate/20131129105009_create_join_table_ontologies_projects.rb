class CreateJoinTableOntologiesProjects < ActiveRecord::Migration
  def change
    create_table :ontologies_projects, :id => false do |t|
      t.integer :ontology_id
      t.integer :project_id
    end
  end
end
