class CreateSupports < ActiveRecord::Migration
  def change
    create_table :supports do |t|
      t.references :language
      t.references :logic

      t.timestamps
    end

    change_table :supports do |t|
      t.index :language_id
      t.index :logic_id
      t.foreign_key :languages
      t.foreign_key :logics
    end
  end
end
