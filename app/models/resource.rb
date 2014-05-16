class Resource < ActiveRecord::Base
  belongs_to :resourcable
  attr_accessible :kind, :uri

  KINDS = %w( ontohub:alternativeFormalization ontohub:paperSpecification ontohub:informalDescription ontohub:tool ontohub:toolDescription)

end
