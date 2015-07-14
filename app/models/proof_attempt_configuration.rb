class ProofAttemptConfiguration < ActiveRecord::Base
  belongs_to :logic_mapping
  belongs_to :prover
  belongs_to :axiom_selection
  has_one :proof_attempt, dependent: :destroy
  # timeout in seconds
  attr_accessible :timeout
  attr_accessible :locid

  validates :proof_attempt, presence: true

  delegate :axioms, to: :axiom_selection
  delegate :ontology, to: :proof_attempt

  def empty?
    [logic_mapping, prover, timeout, axioms].all?(&:blank?)
  end

  def prove_options
    return @prove_options if @prove_options
    options = {}
    options[:prover] = prover if prover
    options[:timeout] = timeout if timeout
    options[:axioms] = axiom_selection.axioms if axiom_selection.axioms.any?
    @prove_options = Hets::ProveOptions.new(options)
  end

  def generate_locid
    # It's possible that the database columns `locid` and `number` have not yet
    # been created.
    if respond_to?(:locid) && respond_to?(:number)
      self.locid =
        "#{proof_attempt.locid}//#{self.class.to_s.underscore.dasherize}"
    end
  end

  protected

  def self.find_with_locid(locid, _iri = nil)
    where(locid: locid).first
  end
end
