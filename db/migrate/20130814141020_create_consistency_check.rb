class CreateConsistencyCheck < ActiveRecord::Migration
  def change
    create_table :consistency_checks do |t|
      t.references :object, :null => false
      t.references :method, :null => false
      t.string :object_status, :null => false
      t.string :mdthod_status, :null => false
      t.string :model_proof, :null => false

      t.timestamps :null => false
    end
    change_table :consistency_checks do |t|
      t.index :object_id
      t.index :method_id
      t.foreign_key :ontology_versions, :column => :object_id, :dependent => :delete
      t.foreign_key :consistency_check_methods, :column => :method_id, :dependent => :delete
    end
  end
end
