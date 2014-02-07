class CreateAlternativeIris < ActiveRecord::Migration
  def change
    create_table :alternative_iris do |t|
      t.string :iri
      t.references :ontology, null: false

      t.timestamps
    end

    change_table :alternative_iris do |t|
      t.foreign_key :ontologies
      t.index [:ontology_id, :iri], unique: true
    end
  end
end
