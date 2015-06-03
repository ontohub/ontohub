class AddAxiomsCountToOntologies < ActiveRecord::Migration
  def change
    add_column :ontologies, :axioms_count, :integer, default: 0, null: false
  end
end
