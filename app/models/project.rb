class Project < ActiveRecord::Base

  has_and_belongs_to_many :ontologies

  attr_accessible :contact, :description, :homepage, :institution, :name

  validates :name,
    presence: true,
    uniqueness: true,
    length: { within: 0..50 }

  validates :homepage,
    format: {
      with: URI::regexp(Settings.allowed_iri_schemes),
      allow_blank: true
    }

  def to_s
    name
  end

end
