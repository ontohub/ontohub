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
    # It's possible that the database column `number` has not yet been created.
    if respond_to?(:number)
      column = self.class.instance_variable_get(:'@numbering_parent_column')
      max = self.class.where(column => send(column).to_i).maximum('number').to_i
      self.number = max + 1
    end
  end
end
