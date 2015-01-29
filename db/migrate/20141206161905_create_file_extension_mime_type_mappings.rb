class CreateFileExtensionMimeTypeMappings < ActiveRecord::Migration
  def change
    create_table :file_extension_mime_type_mappings do |t|
      t.string :file_extension, null: false
      t.string :mime_type, null: false

      t.timestamps
    end
    add_index :file_extension_mime_type_mappings, :mime_type
  end
end
