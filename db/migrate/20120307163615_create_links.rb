class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.references :source, :null => false
      t.references :target, :null => false
      t.string :kind

      t.timestamps :null => false
    end

    change_table :links do |t|
      t.index :source_id
      t.index :target_id
      t.foreign_key :ontologies, :column => :source_id
      t.foreign_key :ontologies, :column => :target_id
    end
  end
end
