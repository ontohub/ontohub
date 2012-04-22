class CreateLinkVersions < ActiveRecord::Migration
  def change
    create_table :link_versions do |t|
      t.integer :source_id
      t.integer :target_id
      t.integer :version_number
      t.boolean :current
      t.boolean :proof_status
      t.boolean :couse_status

      t.timestamps
    end
  end
end
