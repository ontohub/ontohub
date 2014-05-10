class LanguageMapping < ActiveRecord::Base
  include Resourcable
  include Permissionable

  FAITHFULNESSES = %w( none faithful model_expansive model_bijective embedding sublogic )
  THEOROIDALNESSES = %w( plain simple_theoroidal theoroidal generalised )
  STAND_STATUS = %w( AcademicLiterature ISOStandard Unofficial W3CRecommendation W3CTeamSubmission W3CWorkingGroupNote )
  DEFINED_BY = %w( registry )

  belongs_to :source, class_name: 'Language'
  belongs_to :target, class_name: 'Language'
  belongs_to :user
  has_many :language_adjoints, :foreign_key => :translation_id
  attr_accessible :source_id, :target_id, :source, :target, :iri, :standardization_status, :defined_by, :default, :projection, :faithfulness, :theoroidalness

  validates_presence_of :target, :source, :iri

  def to_s
    "#{iri}: #{source} => #{target}"
  end

  def adjoints
    LanguageAdjoint.where("projection_id = ? OR translation_id = ?", self.id, self.id)
  end

end
