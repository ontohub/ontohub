class CreateOntologyVersions < ActiveRecord::Migration
  def change
    create_table :ontology_versions do |t|
      t.references :user, :null => false
      t.references :ontology, :null => false
      t.references :previous_version
      t.string :source_url
      t.string :raw_file
      t.string :xml_file
      t.string :state, :default => 'pending'
      t.text :last_error
      t.string :checksum
      t.integer :number, :null => false # is this the version number? maybe change into string (e.g. "1.0")

      t.timestamps :null => false
    end

    change_table :ontology_versions do |t|
      t.index :user_id
      t.index [:ontology_id, :number]
      t.index :checksum
      t.index :previous_version_id
      t.foreign_key :users
      t.foreign_key :ontologies, :dependent => :delete
      t.foreign_key :ontology_versions, :column => :previous_version_id
    end
  end
end
