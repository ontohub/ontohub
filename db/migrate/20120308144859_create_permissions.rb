class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.references :subject, :polymorphic => true
      t.references :object, :polymorphic => true
      t.string :role, :null => false, :default => 'editor'
      t.timestamps
    end

    change_table :permissions do |t|
      t.index [:object_id, :object_type, :subject_id, :subject_type],
        :name => 'index_permissions_on_ontology_id_and_polymorphic_subject',
        :unique => true
      t.index [:subject_id, :subject_type]
    end
  end
end
