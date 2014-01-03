class LicenseModel < ActiveRecord::Base

  has_and_belongs_to_many :ontologies

  attr_accessible :name, :description, :url, :ontology_id

  validates :name,
    :presence => true,
    :uniqueness => true

  validates :url,
    :format => { :with => URI::regexp(Settings.allowed_iri_schemes) }

end
