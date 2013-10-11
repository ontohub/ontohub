class GraphDataFetcher

  class UnknownMapping < RuntimeError; end
  class UnknownTarget < RuntimeError; end

  MAPPINGS = {
    Logic => LogicMapping,
    Ontology => Link,
    SingleOntology => Link,
    DistributedOntology => Link,
  }

  TARGET_MAPPINGS = {
    Ontology => Ontology,
    DistributedOntology => Ontology,
    SingleOntology => Ontology,
    Logic => Logic,
  }

  def self.link_for(klass)
    mapping_klass = MAPPINGS[klass]
    raise UnknownMapping if mapping_klass.nil?
    mapping_klass.to_s.to_sym
  end

  def initialize(depth: 3,
                 source: nil,
                 center: nil,
                 target: center.class)
    @center = center
    @depth = depth
    @source, @target = source, target
    determine_target(target)
    determine_source(target) unless source
    @source_table, @target_table = @source.table_name, @target.table_name
  end

  def determine_source(target)
    source = MAPPINGS[target]
    raise UnknownMapping unless source
    @source = source
  end

  def determine_target(target)
    real_target = TARGET_MAPPINGS[target]
    raise UnknownTarget unless real_target
    @target = real_target
  end

  def fetch
    return fetch_for_distributed if @center.is_a?(DistributedOntology)
    node_stmt = build_statement(:node)
    nodes = on_target(node_stmt)
    nodes = [@center] if nodes.empty?
    edge_stmt = build_statement(:edge)
    edges = on_source(edge_stmt)
    [nodes, edges]
  end

  private
  def fetch_for_distributed
    func_stmt = <<-SQL
      (SELECT fetch_distributed_graph_data(#{@center.id}))
    SQL
    edges = on_source(@center.id, '"ontology_id" =')
    nodes = on_target(func_stmt)
    [nodes, edges]
  end

  def on_source(stmt, portion='"id" IN')
    @source.where("\"#{@source_table}\".#{portion} #{stmt}")
  end

  def on_target(stmt, portion='"id" IN')
    @target.where("\"#{@target_table}\".#{portion} #{stmt}")
  end

  def build_statement(type = :node)
    type = type.to_s
    <<-SQL
    (
    #{init_statement}
    #{gather_statement}
    SELECT "loop_#{@depth-1}"."#{type}_id" FROM "loop_#{@depth-1}"
    )
    SQL
  end

  def init_statement
    <<-SQL
    WITH "loop_0" AS (SELECT "ids".* FROM
      (SELECT ("#{@source_table}"."source_id") AS node_id,
        ("#{@source_table}"."id") AS edge_id
        FROM "#{@source_table}"
        WHERE ("#{@source_table}"."source_id" = #{@center.id} OR
          "#{@source_table}"."target_id" = #{@center.id})
      UNION
      SELECT ("#{@source_table}"."target_id") AS node_id,
        ("#{@source_table}"."id") AS edge_id
        FROM "#{@source_table}"
        WHERE ("#{@source_table}"."source_id" = #{@center.id} OR
          "#{@source_table}"."target_id" = #{@center.id})) AS ids)
    SQL
  end

  def gather_statement
    stmt_for = ->(depth) do
      before = depth - 1
      stmt = <<-SQL
      "loop_#{depth}" AS (
      SELECT ("#{@source_table}"."source_id") AS node_id,
        ("#{@source_table}"."id") AS edge_id
        FROM "#{@source_table}"
      INNER JOIN "loop_#{before}"
      ON ("#{@source_table}"."source_id" = "loop_#{before}"."node_id" OR
        "#{@source_table}"."target_id" = "loop_#{before}"."node_id")
      UNION
      SELECT ("#{@source_table}"."target_id") AS node_id,
        ("#{@source_table}"."id") AS edge_id
        FROM "#{@source_table}"
      INNER JOIN "loop_#{before}"
      ON ("#{@source_table}"."source_id" = "loop_#{before}"."node_id" OR
        "#{@source_table}"."target_id" = "loop_#{before}"."node_id"))
      SQL
    end

    gather_stmt = ((@depth-1) > 0) ? ", " : ""

    (@depth-1).times do |current_depth|
      current_depth = current_depth + 1
      gather_stmt << stmt_for.call(current_depth)
      gather_stmt << ", " unless current_depth == @depth-1
    end

    gather_stmt
  end

end
