class ProofAttemptConfiguration < ActiveRecord::Base
  belongs_to :logic_mapping
  belongs_to :prover
  belongs_to :axiom_selection
  has_one :proof_attempt, dependent: :destroy
  has_one :theorem, through: :proof_attempt
  # timeout in seconds
  attr_accessible :timeout

  validates :proof_attempt, presence: true

  has_many :axioms, through: :axiom_selection
  has_one :ontology, through: :proof_attempt

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
end
