class ProofAttemptConfiguration < ActiveRecord::Base
  include Numbering
  numbering_parent_column 'ontology_id'

  belongs_to :logic_mapping
  belongs_to :prover
  belongs_to :ontology
  belongs_to :axiom_selection
  has_many :proof_attempts, dependent: :destroy
  has_and_belongs_to_many :goals,
                          class_name: 'Theorem',
                          association_foreign_key: 'sentence_id',
                          join_table: 'goals_proof_attempt_configurations'
  # timeout in seconds
  attr_accessible :timeout
  attr_accessible :locid

  validates :ontology, presence: true
  before_create :generate_locid

  delegate :axioms, to: :axiom_selection

  def empty?
    [logic_mapping, prover, timeout, axioms, goals].all?(&:blank?)
  end

  protected

  def self.find_with_locid(locid, _iri = nil)
    where(locid: locid).first
  end

  def generate_locid
    # It's possible that the database columns `locid` and `number` have not yet
    # been created.
    if respond_to?(:locid) && respond_to?(:number)
      self.locid =
        "#{ontology.locid}//#{self.class.to_s.underscore.dasherize}-#{number}"
    end
  end
end
