class CreateLogicMappings < ActiveRecord::Migration
  def change
    create_table :logic_mappings do |t|
      t.references :source, :null => false
      t.references :target, :null => false
      t.string :iri
      t.string :kind
      t.string :standardization_status
      t.string :defined_by
      t.boolean :default # is a default mapping
      t.boolean :projection # or translation
      t.string :faithfulness
      t.string :theoroidalness

      t.timestamps :null => false
    end

    change_table :logic_mappings do |t|
      t.index :source_id
      t.index :target_id
      t.foreign_key :logics, :column => :source_id, :dependent => :delete
      t.foreign_key :logics, :column => :target_id, :dependent => :delete
    end
  end
end
