class FormalityLevel < ActiveRecord::Base

  scope :not_empty, joins(:ontologies).group("formality_levels.id")

  has_many :ontologies

  attr_accessible :name, :description

  validates :name,
    presence: true,
    uniqueness: true,
    length: { within: 0..50 }

  def to_s
    name
  end

  def name_with_ontology_count
    "#{self.to_s} (#{self.ontologies.count})"
  end
end
