class CreateJoinTableFormalityLevelsOntologies < ActiveRecord::Migration
  def change
    create_table :formality_levels_ontologies, :id => false do |t|
      t.integer :formality_level_id
      t.integer :ontology_id
    end
  end
end
