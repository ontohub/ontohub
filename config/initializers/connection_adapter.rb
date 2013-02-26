class ActiveRecord::ConnectionAdapters::AbstractAdapter
  def ilike_operator
    if ActiveRecord::ConnectionAdapters::PostgreSQLAdapter === self
      "ILIKE"
    else
      # in MySQL there is no ILIKE operator. LIKE is already case insensitive. 
      "LIKE"
    end
  end
end