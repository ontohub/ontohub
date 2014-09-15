class MoveToBelongsToForOntologiesFormalityLevels < ActiveRecord::Migration
  def up
    FormalityLevel.find_each do |form|
      if form.ontologies.any?
        form.ontologies.each do |ont|
          ont.formality_level_id = form.id
          ont.save!
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

    Ontology.find_each do |ont|
      if ont.formality_level_id
        ont.formality_levels << FormalityLevel.find(ont.formality_level_id)
        ont.save!
      end
    end
  end
end
