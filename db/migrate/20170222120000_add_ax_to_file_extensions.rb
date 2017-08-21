class AddAxToFileExtensions < ActiveRecord::Migration
  def up
    populate_database_with_ontology_file_extensions
    populate_database_with_file_extension_mime_type_mappings
  end

  def populate_database_with_ontology_file_extensions
    file_extensions_single = %w[ax p]
    file_extensions_single.map! { |e| ".#{e}" }
    file_extensions_single.each do |ext|
      ActiveRecord::Base.connection.execute(
        "INSERT INTO ontology_file_extensions (extension, distributed) VALUES ('#{ext}', 'false')")
    end
  end

  def populate_database_with_file_extension_mime_type_mappings
    mappings = [
      %w(.ax text/tptp),
      %w(.p text/tptp),
      %w(.tptp text/tptp),
    ]

    mappings.each do |(file_extension, mime_type)|
      FileExtensionMimeTypeMapping.
        where(file_extension: file_extension, mime_type: mime_type).
        first_or_create!
    end
  end
end
