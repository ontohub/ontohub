class CreatePersistedErrors < ActiveRecord::Migration
  def change
    create_table :persisted_errors do |t|
      t.text :short_message
      t.text :message_body
      t.text :stack_trace
      t.string :raised_error_class
      t.text :raised_error_message
      t.references :ontology_version

      t.timestamps
    end
    add_index :persisted_errors, :ontology_version_id
  end
end
