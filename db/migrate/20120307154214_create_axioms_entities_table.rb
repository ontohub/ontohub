class CreateAxiomsEntitiesTable < ActiveRecord::Migration
  def change
    create_table :axioms_entities, :id => false do |t|
      t.references :axiom, :null => false
      t.references :entity, :null => false
      t.references :ontology, :null => false
    end

    add_index :axioms_entities, [:axiom_id, :entity_id] #, :unique => true
    add_index :axioms_entities, [:entity_id, :axiom_id]

    add_index :axioms_entities, [:entity_id, :ontology_id], :unique => true
    add_index :axioms_entities, [:axiom_id,  :ontology_id], :unique => true

    execute "ALTER TABLE axioms ADD FOREIGN KEY (id, ontology_id)
      REFERENCES axioms_entities (axiom_id, ontology_id) ON DELETE CASCADE"

    execute "ALTER TABLE entities ADD FOREIGN KEY (id, ontology_id)
      REFERENCES axioms_entities (entity_id, ontology_id) ON DELETE CASCADE"
  end
end
