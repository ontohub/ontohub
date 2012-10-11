class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :name, :null => false
      t.string :iri, :null => false
      t.text :description # in registry: comment
      t.string :standardization_status
      t.string :defined_by

      t.timestamps :null => false
    end
    change_table :languages do |t|
      t.index :name, :unique => true
      t.index :iri, :unique => true
    end
  end
end
