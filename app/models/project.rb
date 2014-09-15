class Project < ActiveRecord::Base

  scope :not_empty, joins(:ontologies).group("projects.id")

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

  def display_name
    if name.include?('Project')
      name
    else
      "Project #{name}"
    end
  end

  def to_s
    name
  end

  def name_with_ontology_count
    "#{self.to_s} (#{self.ontologies.count})"
  end

end
