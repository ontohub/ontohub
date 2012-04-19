class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :name, :null => false
      t.string :iri, :null => false
      t.text :description

      t.timestamps :null => false
    end
    change_table :languages do |t|
      t.index :name, :unique => true
      t.index :iri, :unique => true
    end
  end
end
