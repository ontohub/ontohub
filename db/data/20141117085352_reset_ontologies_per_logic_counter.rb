class ResetOntologiesPerLogicCounter < ActiveRecord::Migration
  def up
    Logic.find_each { |l| Logic.reset_counters(l.id, :ontologies) }
  end

  # the same as the up, as consistency should always be ensured
  alias_method :down, :up
end
