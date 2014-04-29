module GraphStructures
  module SqlHelper

    def sql
      connection = ActiveRecord::Base.connection
      if block_given?
        yield connection
      else
        connection
      end
    end

    def pluck_select(query, *column_names)
      sql.select_all(sanitize(query)).reduce([]) do |column_values, column|
        values = column_names.map { |name| column[name.to_s] }
        column_values << (values.length > 1 ? values : values.first)
        column_values
      end
    end

    def sanitize(query)
      ActiveRecord::Base.send(:sanitize_sql_array, query)
    end

  end
end
