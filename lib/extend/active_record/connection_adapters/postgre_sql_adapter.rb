class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter < ActiveRecord::ConnectionAdapters::AbstractAdapter
  # Lists all self-defined types in the local postgresql database system.
  # This only pertains to PostgreSQL and their Type-System.
  #
  # * *Returns* :
  # * - Array of Strings which represent a defined type.
  def types
    query("SELECT t.typname as typename
FROM pg_type t
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
WHERE (t.typrelid = 0 OR (SELECT c.relkind = 'c' FROM pg_catalog.pg_class c WHERE c.oid = t.typrelid))
AND NOT EXISTS(SELECT 1 FROM pg_catalog.pg_type el WHERE el.oid = t.typelem AND el.typarray = t.oid)
AND n.nspname NOT IN ('pg_catalog', 'information_schema')
", 'SCHEMA').flatten
  end
end
