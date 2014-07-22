class AddPathToOntologyVersion < ActiveRecord::Migration
  def up
    add_column :ontology_versions, :basepath, :string, null: true
    add_column :ontology_versions, :file_extension, :string, limit: 20

    Ontology.all.each do |o|
      o.versions.each do |v|
        v.basepath = o.read_attribute(:basepath)
        v.file_extension = o.read_attribute(:file_extension)
        v.save!
      end
    end
  end

  def down
    Ontology.all.each do |o|
      if o.current_version
        o.basepath = o.current_version.basepath
        o.file_extension = o.current_version.file_extension
      end
    end

    remove_column :ontology_versions, :basepath
    remove_column :ontology_versions, :file_extension
  end
end
