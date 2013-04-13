class CreateOopsRequests < ActiveRecord::Migration
  def change
    create_table :oops_requests do |t|
      t.references :ontology_version, null: false
      t.string :state, default: 'pending', null: false
      t.string :last_error

      t.timestamps null: false
    end

    change_table :oops_requests do |t|
      t.index :ontology_version_id
      t.foreign_key :ontology_versions, dependent: :delete
    end
  end
end
