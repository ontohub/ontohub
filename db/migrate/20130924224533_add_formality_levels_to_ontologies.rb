class AddFormalityLevelsToOntologies < ActiveRecord::Migration
  def change
    create_table :formality_levels do |t|
      t.string :name
      t.string :description

      t.timestamps
    end

    change_table :formality_levels do |t|
      t.index :name, :unique => true
    end

    change_table :ontologies do |t|
      t.integer :formality_level_id
      t.index :formality_level_id
      t.foreign_key :formality_levels
    end

  end
end
