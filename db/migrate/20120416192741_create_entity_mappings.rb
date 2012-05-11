class CreateEntityMappings < ActiveRecord::Migration
  def change
    create_table :entity_mappings do |t|
      t.references :link_version, :null => false
      t.references :source, :null => false
      t.references :target, :null => false
      t.integer :confidence
      t.string :kind

      t.timestamps :null => false
    end
    change_table :entity_mappings do |t|
      t.index :link_version_id
      t.index :source_id
      t.index :target_id
      t.foreign_key :link_versions, :column => :link_version_id, :dependent => :delete
      t.foreign_key :entities, :column => :source_id, :dependent => :delete
      t.foreign_key :entities, :column => :target_id, :dependent => :delete
    end
  end
end
