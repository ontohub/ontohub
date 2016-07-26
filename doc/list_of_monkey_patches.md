# List of Monkey Patches

We extend some library classes by methods that should be in there and slightly patch classes/modules to support our architecture.
Here is a list of our patches.

## Array
Patched in [lib/extend/array.rb](https://github.com/ontohub/ontohub/tree/staging/lib/extend/array.rb).

Added methods:
* `Array#sample!`
* `Array#head`
* `Array#tail`

## File
Patched in [lib/extend/file.rb](https://github.com/ontohub/ontohub/tree/staging/lib/extend/file.rb).

Added methods:
* `File.basepath`
* `File.relative_path`

## ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
Patched in [lib/extend/active_record/connection_adapters/postgre_sql_adapter.rb](https://github.com/ontohub/ontohub/tree/staging/lib/extend/active_record/connection_adapters/postgre_sql_adapter.rb).

Added methods:
* `PostgreSQLAdapter#types`
