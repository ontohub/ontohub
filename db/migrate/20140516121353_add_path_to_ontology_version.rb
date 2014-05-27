class AddPathToOntologyVersion < ActiveRecord::Migration
  def change
    add_column :ontology_versions, :basepath, :string, null: true
    add_column :ontology_versions, :file_extension, :string, limit: 20

    Ontology.all.each do |o|
      o.versions.each do |v|
        v.basepath = o.basepath
        v.file_extension = o.file_extension
        v.save!
      end
    end
  end
end
