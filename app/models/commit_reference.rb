class CommitReference
  attr_accessor :id

  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  def initialize(id)
    @id = id
  end

  def persisted?
    false
  end
end
