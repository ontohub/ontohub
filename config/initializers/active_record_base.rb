class ActiveRecord::Base

  # Rails does not like self.inherited to be overwritten.
  # Because `include ScopeBuilder` does not work as expetected
  # we need to do this dirty hack.
  def self.inherited_with_foo(base)
    base.send :include, ScopeBuilder
    inherited_without_foo(base)
  end
  class << self
    alias_method_chain :inherited, :foo
  end


  def self.execute_sql(*args)
    sql = self.send :sanitize_sql_array, args
    self.connection.execute sql
  end
end
