class CreateEntityMappings < ActiveRecord::Migration
  def change
    create_table :entity_mappings do |t|
      t.integer :source_id
      t.integer :target_id
      t.integer :confidence
      t.string :kind

      t.timestamps
    end
  end
end
