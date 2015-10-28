class AddIndexOnSineCommonness < ActiveRecord::Migration
  def change
    # We only want to send queries like
    # SELECT "symbols".*, "sine_symbol_commonnesses".*
    #   FROM "symbols" LEFT OUTER JOIN "sine_symbol_commonnesses" ON "sine_symbol_commonnesses"."symbol_id" = "symbols"."id"
    #   ORDER BY sine_symbol_commonnesses.commonness ASC LIMIT 1
    # Thus, we also add an index on the commonness.
    add_index :sine_symbol_commonnesses, :commonness
  end
end
