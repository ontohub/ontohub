class AddCycleCheckerToEEdges < ActiveRecord::Migration
  include Dagnabit::Migration

  def up
    create_cycle_check_trigger :e_edges
  end

  def down
    drop_cycle_check_trigger :e_edges
  end

end
