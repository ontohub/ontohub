class CreateConsistencyCheck < ActiveRecord::Migration
  def change
    create_table :consistency_checks do |t|
      t.references :checker
      t.references :object
      t.integer :priority_order
      t.string :result_status, :null => false
      t.string :result_proof, :null => false
      t.string :process_status, :null => false
      t.timestamps
    end

    change_table :consistency_checks do |t|
      t.index :checker_id
      t.index :object_id
      t.foreign_key :consistency_checkers, :column => :checker_id, :dependent => :delete
      t.foreign_key :ontology_versions, :column => :object_id, :dependent => :delete
    end
  end
end
