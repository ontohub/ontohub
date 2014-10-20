class RemoveXmlPathFromOntologyVersions < ActiveRecord::Migration
  def change
    remove_column :ontology_versions, :pp_xml_name
    remove_column :ontology_versions, :xml_name
  end
end
