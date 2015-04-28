class ProofAttemptConfiguration < ActiveRecord::Base
  include Numbering
  numbering_parent_column 'ontology_id'

  belongs_to :logic_mapping
  belongs_to :prover
  belongs_to :ontology
  has_many :proof_attempts, dependent: :destroy
  has_and_belongs_to_many :axioms,
                          class_name: 'Axiom',
                          association_foreign_key: 'sentence_id',
                          join_table: 'axioms_proof_attempt_configurations'
  has_and_belongs_to_many :goals,
                          class_name: 'Theorem',
                          association_foreign_key: 'sentence_id',
                          join_table: 'goals_proof_attempt_configurations'
  # timeout in seconds
  attr_accessible :timeout
  attr_accessible :locid

  validates :ontology, presence: true
  before_create :generate_locid

  protected

  def self.find_with_locid(locid, _iri = nil)
    where(locid: locid).first
  end

  def generate_locid
    self.locid =
      "#{ontology.locid}//#{self.class.to_s.underscore.dasherize}-#{number}"
  end
end
