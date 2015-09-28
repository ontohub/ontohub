class AddFileExtensionP < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.
      execute("INSERT INTO ontology_file_extensions (extension, distributed) VALUES ('.p', 'false')")
  end

  def down
    ActiveRecord::Base.connection.
      execute("DELETE FROM ontology_file_extensions WHERE extension='.p'")
  end
end
