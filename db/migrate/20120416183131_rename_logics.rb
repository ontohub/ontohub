class RenameLogics < ActiveRecord::Migration
  def up
    add-column :logics, :iri, :string
    add-column :ontologies, :language_id, :integer
    add-column :ontologies, :current_version_id, :integer
    add-column :ontology_versions, :version_number, :integer
    add-column :ontology_versions, :current, :boolean
    add-column :link, :iri, :string
    add-column :link, :current_version_id, :integer
  end

  def down
    remove :logics, :uri
    remove :logics, :extension
    remove :logics, :mimetype
    remove :ontologies, :logic
  end
end
