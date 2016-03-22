class ProofStatus < LocIdBaseModel
  include ProofStatus::CreationFromOntology

  DEFAULT_OPEN_STATUS = 'OPN'
  DEFAULT_PROVEN_STATUS = 'THM'
  DEFAULT_DISPROVEN_STATUS = 'CSA'
  DEFAULT_DISPROVEN_ON_SUBSET = 'CSAS'
  DEFAULT_UNKNOWN_STATUS = 'UNK'
  CONTRADICTORY = 'CONTR'

  self.primary_key = :identifier

  attr_accessible :label,
                  :description,
                  :identifier,
                  :name,
                  :solved,
                  :locid

  alias_attribute :to_s, :identifier
  alias_attribute :to_param, :identifier
  alias_attribute :solved?, :solved

  validates_presence_of :label

  before_create :generate_locid

  protected

  def generate_locid
    LocId.where(locid: "/proof-statuses/#{identifier}",
                assorted_object_id: id,
                assorted_object_type: self.class.to_s,
               ).first_or_create!
  end
end
