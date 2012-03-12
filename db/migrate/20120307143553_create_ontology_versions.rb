class CreateOntologyVersions < ActiveRecord::Migration
  def change
    create_table :ontology_versions do |t|
      t.references :user, :null => false
      t.references :ontology, :null => false
      t.string :source_uri
      t.string :raw_file
      t.string :xml_file
      t.string :last_error

      t.timestamps :null => false
    end

    change_table :ontology_versions do |t|
      t.index :user_id
      t.index :ontology_id
      t.foreign_key :users
      t.foreign_key :ontologies, :dependent => :delete
    end
  end
end
