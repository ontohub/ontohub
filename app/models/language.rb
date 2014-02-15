class Language < ActiveRecord::Base
  include Resourcable
  include Permissionable
  
  STAND_STATUS = %w( AcademicLiterature ISOStandard Unofficial W3CRecommendation W3CTeamSubmission W3CWorkingGroupNote )
  DEFINED_BY = %w( registry )

  has_many :supports
  has_many :language_adjoints
  has_many :ontologies
  has_many :serializations
  has_many :language_mappings, :foreign_key => :source_id
  
  belongs_to :user

  attr_accessible :name, :iri, :description, :standardization_status, :defined_by

  validates :name, length: { minimum: 1 }

  validates :iri, length: { minimum: 1 }
  validates_uniqueness_of :iri, if: :iri_changed?
  validates_format_of :iri, with: URI::regexp(Settings.allowed_iri_schemes)

  after_create :add_permission
  
  scope :autocomplete_search, ->(query) {
    where("name ILIKE ?", "%" << query << "%")
  }

  def to_s
    name
  end
  
  def add_logic(logic)
    sup = self.supports.new
    sup.logic = logic
    sup.save!
  end
  
    def mappings_from
    LanguageMapping.where source_id: self.id
  end
  
  def mappings_to
    LanguageMapping.where(target_id: self.id)
  end

end
