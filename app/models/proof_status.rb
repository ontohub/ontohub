class ProofStatus < ActiveRecord::Base
  include ProofStatus::CreationFromOntology
  include Slug

  DEFAULT_OPEN_STATUS = 'OPN'
  DEFAULT_PROVEN_STATUS = 'THM'
  DEFAULT_DISPROVEN_STATUS = 'CSA'
  DEFAULT_DISPROVEN_ON_SUBSET = 'CSAS'
  DEFAULT_UNKNOWN_STATUS = 'UNK'
  DEFAULT_TIMEOUT_STATUS = 'TMO'
  CONTRADICTORY = 'CONTR'

  self.primary_key = :identifier

  attr_accessible :label,
                  :description,
                  :identifier,
                  :name,
                  :solved

  alias_attribute :to_s, :identifier
  alias_attribute :to_param, :identifier
  alias_attribute :solved?, :solved

  validates_presence_of :label

  slug_base :identifier
end
