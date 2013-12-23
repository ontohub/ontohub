class OntologyType < ActiveRecord::Base

  has_many :ontologies

  attr_accessible :name, :description, :documentation

  validates :name,
    :presence => true

  validates :description,
    :presence => true

  validates :documentation,
    :format => { :with => URI::regexp(Settings.allowed_iri_schemes) }

  def to_s
    name
  end
end
