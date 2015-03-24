class ProofStatus < ActiveRecord::Base
  include ProofStatus::CreationFromOntology

  DEFAULT_OPEN_STATUS = 'OPN'
  DEFAULT_PROVEN_STATUS = 'THM'
  DEFAULT_DISPROVEN_STATUS = 'NOC'
  DEFAULT_UNKNOWN_STATUS = 'UNK'

  self.primary_key = :identifier

  attr_accessible :label, :description, :identifier, :name, :solved

  validates_presence_of :label

  def to_s
    identifier
  end

  def to_param
    identifier
  end

  def solved?
    solved
  end
end
