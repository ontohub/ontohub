module Numbering
  extend ActiveSupport::Concern

  included do
    before_create :generate_number
  end

  module ClassMethods
    def numbering_parent_column(column_name)
      @numbering_parent_column = column_name
    end
  end

  def generate_number
    column = self.class.instance_variable_get(:'@numbering_parent_column')
    sql = <<-SQL
      SELECT MAX(number)
      FROM #{self.class.table_name}
      WHERE #{column}=#{send(column).to_i}
    SQL
    self.number = connection.select_value(sql).to_i + 1
  end
end
