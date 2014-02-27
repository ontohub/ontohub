class Task < ActiveRecord::Base

  has_many :ontologies

  attr_accessible :name, :description

  validates :name,
    presence: true,
    uniqueness: true,
    length: { within: 0..50 }

  def to_s
    name
  end

end
