class Logic < ActiveRecord::Base
  include Resourcable
  include Permissionable
  include Common::Scopes
  
  STAND_STATUS = %w( AcademicLiterature ISOStandard Unofficial W3CRecommendation W3CTeamSubmission W3CWorkingGroupNote )
  DEFINED_BY = %w( registry )
  
  has_many :ontologies
  has_many :supports
  
  belongs_to :user

  attr_accessible :name, :iri, :description, :standardization_status, :defined_by

  validates_presence_of :name
  validates_uniqueness_of :name, if: :name_changed?

  validates_presence_of :iri
  validates_uniqueness_of :iri, if: :iri_changed?
  #validates_format_of :iri, with: URI::regexp(ALLOWED_URI_SCHEMAS)

  scope :autocomplete_search, ->(query) {
    where("name LIKE ?", "%" << query << "%")
  }

  def to_s
    name
  end
  
  def addLanguage(language)
    sup = self.supports.new
    sup.language = language
    sup.save!
  end
  
end
