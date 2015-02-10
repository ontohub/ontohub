class MoveToBelongsToForOntologiesFormalityLevels < ActiveRecord::Migration
  def up
    drop_table(:formality_levels_ontologies)
  end

  def down
    create_table(:formality_levels_ontologies, id: false) do |t|
      t.column(:ontology_id, :integer, null: false)
      t.column(:formality_level_id, :integer, null: false)
    end
  end
end
