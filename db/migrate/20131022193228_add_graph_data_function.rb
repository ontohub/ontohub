class AddGraphDataFunction < ActiveRecord::Migration
  $function_declaration = "fetch_graph_data(center_id integer, source_tbl regclass, target_tbl regclass, depth integer)"
  def up
    execute <<-SQL
CREATE TYPE graph_data_type AS (
  node_id integer,
  edge_id integer,
  depth integer
);

CREATE OR REPLACE FUNCTION #{$function_declaration}
    RETURNS SETOF graph_data_type AS $$
BEGIN
RETURN QUERY EXECUTE format('
  WITH RECURSIVE graph_data(node_id, edge_id, depth) AS (
      (WITH mergeable AS (
        SELECT (%s."source_id") AS source_id,
          (%s."target_id") AS target_id,
          (%s."id") AS edge_id,
          1 AS depth
        FROM %s
        WHERE (%s."source_id" = %s OR
          %s."target_id" = %s)
        )
        SELECT (source_id) AS node_id, edge_id, depth FROM mergeable
        UNION
        SELECT (target_id) AS node_id, edge_id, depth FROM mergeable
      )
    UNION ALL
      (WITH mergeable AS (
        SELECT (%s."source_id") AS source_id,
          (%s."target_id") AS target_id,
          (%s."id") AS edge_id,
          (graph_data.depth+1) AS depth
        FROM %s
        INNER JOIN graph_data
        ON (%s."source_id" = "graph_data"."node_id" OR
          %s."target_id" = "graph_data"."node_id")
        WHERE graph_data.depth < %s)
      SELECT (source_id) AS node_id, edge_id, depth FROM mergeable
      UNION
      SELECT (target_id) AS node_id, edge_id, depth FROM mergeable
    )
  )
  SELECT DISTINCT * from graph_data;
', source_tbl, source_tbl, source_tbl,
source_tbl, source_tbl, center_id,
source_tbl, center_id,
source_tbl, source_tbl, source_tbl,
source_tbl, source_tbl, source_tbl,
depth);
END;
$$ language plpgsql;
    SQL
  end

  def down
    execute <<-SQL
DROP FUNCTION #{$function_declaration};
DROP TYPE graph_data_type;
    SQL
  end
end
