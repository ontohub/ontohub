class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members, :id => false do |t|
      t.references :ontology_version, :null => false
      t.references :distributed_ontology_version, :null => false
    end

    add_index :members, [:ontology_version_id, :distributed_ontology_version_id]
    add_index :members, [:distributed_ontology_version_id, :ontology_version_id]

  end
end
