class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members, :id => false do |t|
      # parent ontology
      t.references :distributed_ontology, :null => false
      
      # child ontology
      t.references :ontology, :null => false
    end
    
    change_table :members, :id => false do |t|
      t.index [:ontology_id, :distributed_ontology_id], unique: true
      t.foreign_key :ontologies
      t.foreign_key :ontologies, column: 'distributed_ontology_id'
    end

    #add_index :members, [:ontology_version_id, :distributed_ontology_version_id]
    #add_index :members, [:distributed_ontology_version_id, :ontology_version_id]

  end
end
