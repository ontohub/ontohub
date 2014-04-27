class CreateOntologyFileExtensions < ActiveRecord::Migration
  def change
    create_table :ontology_file_extensions, id: false do |t|
      t.string :extension, :null => false, :unique => true
      t.boolean :distributed, :null => false
    end
  end
end
