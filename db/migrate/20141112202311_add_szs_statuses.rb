class AddSzsStatuses < ActiveRecord::Migration
  def up
    create_table :proof_statuses, id: false do |t|
      t.string :identifier, primary_key: true
      t.string :name
      t.string :label, null: false, default: 'primary'
      t.text :description
      t.boolean :solved
    end

    rename_column :proof_attempts, :status, :proof_status_id
    rename_column :sentences, :proof_status, :proof_status_id
  end

  def down
    remove_table :proof_statuses
  end
end
