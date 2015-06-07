class RemoveIriFromOntology < ActiveRecord::Migration
  def up
    remove_column :ontologies, :iri
  end

  def down
    add_column :ontologies, :iri, :string, null: false
  end
end
