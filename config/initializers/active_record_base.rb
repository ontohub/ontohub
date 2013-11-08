class ActiveRecord::Base
  include ScopeBuilder
  
  def self.execute_sql(*args)     
    sql = self.send :sanitize_sql_array, args
    self.connection.execute sql
  end
end
