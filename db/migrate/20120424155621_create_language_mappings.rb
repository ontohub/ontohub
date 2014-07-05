class CreateLanguageMappings < ActiveRecord::Migration
  def change
    create_table :language_mappings do |t|
      t.references :source, :null => false
      t.references :target, :null => false
      t.string :iri
      t.string :kind
      t.string :standardization_status
      t.string :defined_by

      t.timestamps :null => false
    end

    change_table :language_mappings do |t|
      t.index :source_id
      t.index :target_id
      t.foreign_key :languages, :column => :source_id, :dependent => :delete
      t.foreign_key :languages, :column => :target_id, :dependent => :delete
    end
  end
end
