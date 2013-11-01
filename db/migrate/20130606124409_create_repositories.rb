class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string :path, null: false
      t.string :name, null: false
      t.text :description

      t.timestamps null: false
    end

    change_table :repositories do |t|
      t.index :path, unique: true
    end

    add_column      :ontologies, :repository_id, :integer, null: false
    add_foreign_key :ontologies, :repositories

    add_index :ontologies, [:repository_id, :id], unique: true
    execute "ALTER TABLE ontologies
             ADD FOREIGN KEY (parent_id,repository_id)
             REFERENCES ontologies (id, repository_id)"
  end
end
