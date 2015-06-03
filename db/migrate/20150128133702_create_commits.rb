class CreateCommits < ActiveRecord::Migration
  def change
    create_table :commits do |t|
      t.string :commit_oid, limit: 40, null: false
      t.text :committer
      t.text :author
      t.datetime :author_date
      t.datetime :commit_date
      t.references :repository, null: false

      t.timestamps
    end
    add_index :commits, :commit_oid
    add_index :commits, :author_date
    add_index :commits, :commit_date
    add_index :commits, [:repository_id, :commit_oid], unique: true
    add_index :commits, [:repository_id, :id], unique: true
  end
end
