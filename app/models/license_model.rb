class LicenseModel < ActiveRecord::Base

  scope :not_empty, joins(:ontologies).group("license_models.id")

  has_and_belongs_to_many :ontologies

  attr_accessible :name, :description, :url

  validates :name,
    presence: true,
    uniqueness: true,
    length: { within: 0..50 }

  validates :url,
    presence: true,
    format: {
      with: URI::regexp(Settings.allowed_iri_schemes),
    }

  def to_s
    name
  end

  def name_with_ontology_count
    "#{self.to_s} (#{self.ontologies.count})"
  end

end
