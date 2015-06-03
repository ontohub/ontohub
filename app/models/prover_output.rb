class ProverOutput < ActiveRecord::Base
  belongs_to :proof_attempt
  attr_accessible :content, :locid

  before_create :generate_locid

  delegate :ontology, :theorem, :prover, to: :proof_attempt

  protected

  def self.find_with_locid(locid, _iri = nil)
    where(locid: locid).first
  end

  def generate_locid
    self.locid = "#{proof_attempt.locid}//prover-output"
  end
end
