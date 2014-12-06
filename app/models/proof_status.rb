class ProofStatus < ActiveRecord::Base
  include ProofStatus::CreationFromOntology

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
