class CodeReference < ActiveRecord::Base
  belongs_to :referencee, polymorphic: true

  attr_accessible :begin_column, :begin_line
  attr_accessible :end_column, :end_line
  attr_accessible :referencee, :referencee_id

end
