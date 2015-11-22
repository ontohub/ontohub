class ProofStatus < ActiveRecord::Base
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

  def self.find_with_locid(locid, _iri = nil)
    where(locid: locid).first
  end

  protected

  def generate_locid
    self.locid = "/proof-statuses/#{identifier}"
  end
end
