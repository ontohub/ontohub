class MoveToBelongsToForOntologiesFormalityLevels < ActiveRecord::Migration
  def up
    FormalityLevel.find_each do |formality_level|
      if formality_level.ontologies.any?
        formality_level.ontologies.each do |ontology|
          ontology.formality_level_id = formality_level.id
          ontology.save!
        end
      end
    end

    drop_table(:formality_levels_ontologies)
  end

  def down
    create_table(:formality_levels_ontologies, id: false) do |t|
      t.column(:ontology_id, :integer, null: false)
      t.column(:formality_level_id, :integer, null: false)
    end

    Ontology.find_each do |ontology|
      if ontology.formality_level_id
        ontology.formality_levels << FormalityLevel.
          find(ontology.formality_level_id)
        ontology.save!
      end
    end
  end
end
