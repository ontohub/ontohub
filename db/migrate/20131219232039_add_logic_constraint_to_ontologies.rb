class AddLogicConstraintToOntologies < ActiveRecord::Migration
  def up
    execute <<-SQL
ALTER TABLE ontologies
ADD CONSTRAINT logic_id_check CHECK (state != 'done' OR logic_id IS NOT NULL OR type = 'DistributedOntology')
    SQL
  end

  def down
    execute <<-SQL
ALTER TABLE ontologies
DROP CONSTRAINT IF EXISTS logic_id_check
    SQL
  end
end
