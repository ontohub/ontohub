class RemoveCycleCheckerFromEEdges < ActiveRecord::Migration
  include Dagnabit::Migration

  def up
    drop_cycle_check_trigger :e_edges
  end

  def down
  end
end
