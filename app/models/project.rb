class Project < ActiveRecord::Base

  has_many :ontologies

  attr_accessible :contact, :description, :homepage, :institution, :name

  validates :name,
    :presence => true

  validates :name,
    :presence => true

  validates :homepage,
    :format => { :with => URI::regexp(Settings.allowed_iri_schemes) }

end
