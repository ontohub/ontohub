class CreateOrganisations < ActiveRecord::Migration
  def change
    create_table :organisations do |t|
      t.string :name
      t.string :acronym
      t.text :description
      t.string :url

      t.timestamps
    end
  end
end
