class CreatePermission < ActiveRecord::Migration
  def change
    create_table :permission do |t|
      t.references :owner, :polymorphic => true
      t.references :ontology
      t.timestamps
    end

    change_table :permission do |t|
      t.index [:ontology_id, :owner_id, :owner_type], :unique => true
      t.foreign_key :ontologies, :dependent => :delete
    end
  end
end
