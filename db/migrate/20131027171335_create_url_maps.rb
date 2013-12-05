class CreateUrlMaps < ActiveRecord::Migration
  def change
    create_table :url_maps do |t|
      t.string :source, :null => false
      t.string :target, :null => false
      t.references :repository, :null => false

      t.timestamps
    end

    change_table :url_maps do |t|
      t.foreign_key :repositories
      t.index [:repository_id, :source], unique: true
    end
  end
end
