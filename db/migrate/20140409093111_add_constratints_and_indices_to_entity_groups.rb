class AddConstratintsAndIndicesToEntityGroups < ActiveRecord::Migration
  def change
    change_column :entity_groups, :name, :text, :null => false


    change_table :entity_groups do |t|
      t.index [:ontology_id, :id], :unique => true
      t.index [:ontology_id, :name], :unique => true
      t.foreign_key :ontologies, :dependent => :delete
    end
  end
end
