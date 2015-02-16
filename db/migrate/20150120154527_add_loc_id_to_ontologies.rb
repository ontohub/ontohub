class AddLocIdToOntologies < ActiveRecord::Migration
  def change
    add_column :ontologies, :locid, :text
  end
end
