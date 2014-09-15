class OntologyType < ActiveRecord::Base

  scope :not_empty, joins(:ontologies).group("ontology_types.id")

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

  def name_with_ontology_count
    "#{self.to_s} (#{self.ontologies.count})"
  end

end
