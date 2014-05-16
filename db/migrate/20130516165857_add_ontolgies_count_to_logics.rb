class AddOntolgiesCountToLogics < ActiveRecord::Migration
  def self.up
    add_column :logics, :ontologies_count, :integer, default: 0

    Logic.reset_column_information
    Logic.find_each do |l|
      Logic.reset_counters l.id, :ontologies
    end
  end

  def self.down
    remove_column :logics, :ontologies_count
  end
end
