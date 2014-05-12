class CreateLinkVersions < ActiveRecord::Migration
  def change
    create_table :link_versions do |t|
      t.references :link, :null => false
      t.references :source, :null => false
      t.references :target, :null => false
      t.references :aux_link #  corresponds to GMorphism in HidingFreeOrCofreeThm in Hets
      t.integer :version_number
      t.boolean :current
      t.boolean :proof_status, :default => false
      t.string :required_cons_status, :default => "none"
      t.string :proven_cons_status, :default => "none"

      t.timestamps :null => false
    end

    change_table :link_versions do |t|
      t.index :link_id
      t.index :source_id
      t.index :target_id
      t.foreign_key :links, :dependent => :delete
      t.foreign_key :ontology_versions, :column => :source_id, :dependent => :delete
      t.foreign_key :ontology_versions, :column => :target_id, :dependent => :delete
    end
  end
end
