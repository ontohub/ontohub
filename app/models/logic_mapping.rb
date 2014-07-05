class LogicMapping < ActiveRecord::Base
  include Resourcable
  include Permissionable

  FAITHFULNESSES = %w( not_faithful faithful model_expansive model_bijective embedding sublogic )
  THEOROIDALNESSES = %w( plain simple_theoroidal theoroidal generalized )
  EXACTNESSES = %w( not_exact weakly_mono_exact weakly_exact exact )
  STAND_STATUS = %w( AcademicLiterature ISOStandard Unofficial W3CRecommendation W3CTeamSubmission W3CWorkingGroupNote )
  DEFINED_BY = %w( registry )

  belongs_to :source, class_name: 'Logic'
  belongs_to :target, class_name: 'Logic'
  belongs_to :user
  has_many :logic_adjoints, :foreign_key => :translation_id
  attr_accessible :source_id, :target_id, :source, :target, :iri, :standardization_status, :defined_by, :default, :projection, :faithfulness, :theoroidalness, :exactness, :user

  validates_presence_of :target, :source, :iri

  def to_s
    "#{iri}: #{source} => #{target}"
  end

  def adjoints
    LogicAdjoint.where("projection_id = ? OR translation_id = ?", self.id, self.id)
  end

end
