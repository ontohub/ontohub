class GraphDataFetcher

  def initialize(depth: 3,
                 source: LogicMapping,
                 center: nil,
                 target: center.class)
    @source_table, @target_table = source.table_name, target.table_name
    @source, @target = source, target
    @center = center
    @depth = depth
  end

  def fetch
    stmt = build_statement
    nodes = @target.where("\"#{@target_table}\".\"id\" IN #{stmt}")
  end

  private
  def build_statement
    <<-SQL
    (
    #{init_statement}
    #{gather_statement}
    SELECT "loop_#{@depth-1}"."id" FROM "loop_#{@depth-1}"
    )
    SQL
  end

  def init_statement
    <<-SQL
    WITH "loop_0" AS (SELECT "ids"."id" FROM
      (SELECT ("#{@source_table}"."source_id") AS id FROM "#{@source_table}"
    WHERE ("#{@source_table}"."source_id" = #{@center.id} OR
      "#{@source_table}"."target_id" = #{@center.id})
    UNION
    SELECT ("#{@source_table}"."target_id") AS id FROM "#{@source_table}"
    WHERE ("#{@source_table}"."source_id" = #{@center.id} OR
      "#{@source_table}"."target_id" = #{@center.id})) AS ids)
    SQL
  end

  def gather_statement
    stmt_for = ->(depth) do
      before = depth - 1
      stmt = <<-SQL
      "loop_#{depth}" AS (
      SELECT ("#{@source_table}"."source_id") AS id FROM "#{@source_table}"
      INNER JOIN "loop_#{before}"
      ON ("#{@source_table}"."source_id" = "loop_#{before}"."id" OR
        "#{@source_table}"."target_id" = "loop_#{before}"."id")
      UNION
      SELECT ("#{@source_table}"."target_id") AS id FROM "#{@source_table}"
      INNER JOIN "loop_#{before}"
      ON ("#{@source_table}"."source_id" = "loop_#{before}"."id" OR
        "#{@source_table}"."target_id" = "loop_#{before}"."id"))
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
