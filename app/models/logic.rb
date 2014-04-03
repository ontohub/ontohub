#
# A named logic in the field of Logics.
#
# Examples:
# * Classical Logic
# * Common Logic
# * Description Logic
# * First-Order Logic
# * Modal Logic
#
class Logic < ActiveRecord::Base
  include Resourcable
  include Permissionable

  # Multiple Class Features
  include Aggregatable

  Logic::DEFAULT_DISTRIBUTED_ONTOLOGY_LOGIC = 'DOL'

  STAND_STATUS = %w( AcademicLiterature ISOStandard Unofficial W3CRecommendation W3CTeamSubmission W3CWorkingGroupNote )
  DEFINED_BY = %w( registry )

  has_many :ontologies
  has_many :supports
  has_many :logic_mappings, :foreign_key => :source_id

  # The creator of this logic in the system
  # The logic creator
  # * is not necessarily an owner nor an editor
  # * may be a current or former user of the system
  # * may be the original logician or anyone else
  belongs_to :user

  attr_accessible :name, :iri, :description, :standardization_status, :defined_by, :user

  validates_presence_of :name
  validates_uniqueness_of :name, if: :name_changed?

  validates_presence_of :iri
  validates_uniqueness_of :iri, if: :iri_changed?
  validates_format_of :iri, with: URI::regexp(Settings.allowed_iri_schemes)

  default_scope order('ontologies_count desc')

  scope :autocomplete_search, ->(query) {
    where("name ILIKE ?", "%" << query << "%")
  }

  def to_s
    name
  end
  
  def add_language(language)
    sup = self.supports.new
    sup.language = language
    sup.save!
  end
  
  def mappings_from
    LogicMapping.find_all_by_source_id self.id
  end
  
  def mappings_to
    LogicMapping.find_all_by_target_id self.id
  end
  
end
