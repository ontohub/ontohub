class ChangeTypeOfIriForOntologies < ActiveRecord::Migration
  def change
    change_column :ontologies, :iri, :text
  end
end
