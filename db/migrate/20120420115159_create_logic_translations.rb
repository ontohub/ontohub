class CreateLogicTranslations < ActiveRecord::Migration
  def change
    create_table :logic_translations do |t|
      t.references :source
      t.references :target
      t.string :iri
      t.string :name
      t.text :description
      t.integer :faithfulness
      t.boolean :plain
      t.integer :exactness

      t.timestamps
    end
  end
end
