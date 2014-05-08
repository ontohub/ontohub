class CreateEntityGroups < ActiveRecord::Migration
  def change
    create_table :entity_groups do |t|
      t.references :ontology
      t.text       :name
      
      t.timestamps
    end
  end
end
