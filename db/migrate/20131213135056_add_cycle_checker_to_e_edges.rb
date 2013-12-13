class AddCycleCheckerToEEdges < ActiveRecord::Migration
  extend Dagnabit::Migration
  def change
  end
  create_cycle_check_trigger :e_edges
end
