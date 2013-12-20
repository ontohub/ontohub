class AddPresentToOntologies < ActiveRecord::Migration
  def change
    add_column :ontologies, :present, :boolean, :default => false
  end
end
