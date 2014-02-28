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
    determine_target(@target)
    determine_source(@target) unless @source
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
    if @center.is_a?(DistributedOntology)
      nodes, edges = fetch_for_distributed
    else
      node_stmt = build_statement(:node)
      nodes = on_target(node_stmt)
      edge_stmt = build_statement(:edge)
      edges = on_source(edge_stmt)
    end
    nodes = [@center] if nodes.empty?
    [nodes, edges]
  end

  def explain
    if @center.is_a?(DistributedOntology)
      @source.
        connection.
        select_all("EXPLAIN (FORMAT JSON) (SELECT fetch_distributed_graph_data(#{@center.id}))")
    else
      @source.
        connection.
        select_all("EXPLAIN (FORMAT JSON) (#{build_statement(:node)})")
    end
  end

  def query_cost
    response = explain
    cost = JSON.parse(response.first["QUERY PLAN"]).
        first["Plan"]["Total Cost"]
    cost
  rescue NoMethodError
    nil
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
    ( SELECT DISTINCT "#{type}_id" FROM fetch_graph_data(#{@center.id}, '#{@source_table}', '#{@target_table}', #{@depth}) )
    SQL
  end

end
