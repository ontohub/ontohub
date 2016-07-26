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

## ActionDispatch::Routing::PolymorphicRoutes
Patched in [lib/extend/action_dispatch/routing/polymorphic_routes.rb](https://github.com/ontohub/ontohub/tree/staging/lib/extend/action_dispatch/routing/polymorphic_routes.rb).

Changed methods:
* `polymorphic_url` is patched to return the Loc/Id if the argument is a `LocIdBaseModel` object.
  Otherwise the default behavior is still used.
  This allows to use `url_for` with an object of type `LocIdBaseModel` and let it return the Loc/Id.
  `url_for(record)` returns the full locid and `url_for([record, command_1, ..., command_n, query_opt_1: val_1, ... query_opt_n: val_n])` returns the full locid with commands and query options.
