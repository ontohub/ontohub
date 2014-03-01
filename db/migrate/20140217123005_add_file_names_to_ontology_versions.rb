class AddFileNamesToOntologyVersions < ActiveRecord::Migration
  def change
    add_column :ontology_versions, :pp_xml_name, :string
    add_column :ontology_versions, :xml_name, :string
  end
end
