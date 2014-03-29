class LicenseModel < ActiveRecord::Base

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

end
