class AddDistributedGraphDataFunction < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION fetch_distributed_graph_data(
  distributed_id integer)
  RETURNS SETOF integer AS $$
BEGIN
  RETURN QUERY WITH "graph_core" AS (
    SELECT "links"."id",
      "links"."target_id",
      "links"."source_id"
      FROM "links"
      WHERE "links"."ontology_id" = distributed_id),
  "graph_data" AS (
    SELECT ("graph_core"."source_id") AS node_id,
      ("graph_core"."id") AS edge_id
       FROM graph_core
    UNION
    SELECT ("graph_core"."target_id") AS node_id,
      ("graph_core"."id") AS edge_id
      FROM graph_core)
  SELECT DISTINCT "graph_data"."node_id"
    FROM "graph_data";
END;
$$ language plpgsql;
    SQL
  end

  def down
    execute <<-SQL
DROP FUNCTION fetch_distributed_graph_data(distributed_id integer);
    SQL
  end
end
