class AddLicenseModelsToOntologies < ActiveRecord::Migration
  def change
    create_table :license_models do |t|
      t.string :name
      t.string :description
      t.string :url

      t.timestamps
    end

    change_table :license_models do |t|
      t.index :name, :unique => true
    end

    change_table :ontologies do |t|
      t.integer :license_model_id
      t.index :license_model_id
      t.foreign_key :license_models
    end

  end
end
