class AddOmnToOntologyFileExtensions < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.
      execute("INSERT INTO ontology_file_extensions (extension, distributed) VALUES ('.omn', 'false')")
  end

  def down
    ActiveRecord::Base.connection.
      execute("DELETE FROM ontology_file_extensions WHERE extension='.omn'")
  end
end
