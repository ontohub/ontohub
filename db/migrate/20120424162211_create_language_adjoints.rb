class CreateLanguageAdjoints < ActiveRecord::Migration
  def change
    create_table :language_adjoints do |t|
      t.references :translation, :null => false
      t.references :projection, :null => false
      t.string :iri
      t.string :kind

      t.timestamps :null => false
    end

    change_table :language_adjoints do |t|
      t.index :translation_id
      t.index :projection_id
      t.foreign_key :language_mappings, :column => :translation_id, :dependent => :delete
      t.foreign_key :language_mappings, :column => :projection_id, :dependent => :delete
    end
  end
end
