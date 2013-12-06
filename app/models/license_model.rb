class LicenseModel < ActiveRecord::Base

  has_many :ontologies

  attr_accessible :name, :description, :url

  validates :name,
    :presence => true,
    :uniqueness => true

  validates :url,
    :format => { :with => URI::regexp(Settings.allowed_iri_schemes) }

end
