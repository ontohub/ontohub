class AddMappingsToFileExtensionMimeTypeMappings < ActiveRecord::Migration
  MAPPINGS = [
    %w(.clif text/clif),
    %w(.owl application/owl),
    %w(.owl text/obo),
    %w(.ttl text/turtle),
    %w(.owx application/owl+xml),
    %w(.casl text/casl),
    %w(.dol text/dol),
    %w(.het text/het),
  ]

  def up
    MAPPINGS.each do |(file_extension, mime_type)|
      FileExtensionMimeTypeMapping.
        where(file_extension: file_extension, mime_type: mime_type).
        first_or_create!
    end
  end

  def down
    MAPPINGS.each do |(file_extension, mime_type)|
      mapping = FileExtensionMimeTypeMapping.
        where(file_extension: file_extension, mime_type: mime_type).first
      mapping.destroy!
    end
  end
end
