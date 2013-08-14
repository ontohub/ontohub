class CreateConsistencyCheckMethod < ActiveRecord::Migration
  def change
    create_table :consistency_check_methods do |t|
      t.references :checker
      t.references :logic
      t.integer :priority_order # is expressiveness of language exactly captured by logic?

      t.timestamps
    end

    change_table :consistency_check_methods do |t|
      t.index :checker_id
      t.index :logic_id
      t.foreign_key :consistency_checkers, :column => :checker_id, :dependent => :delete
      t.foreign_key :logics, :dependent => :delete
    end
  end
end
