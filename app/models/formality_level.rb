class FormalityLevel < ActiveRecord::Base

  has_many :ontologies

  attr_accessible :name, :description

  validates :name,
    :presence => true,
    :uniqueness => true

end
