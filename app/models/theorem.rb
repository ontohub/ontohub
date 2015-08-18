class Theorem < Sentence
  include StateUpdater

  STATUS_ORDER = [ProofStatus::DEFAULT_OPEN_STATUS,
                  # Any status not in this list comes here
                  :any,
                  ProofStatus::DEFAULT_UNKNOWN_STATUS,
                  ProofStatus::DEFAULT_DISPROVEN_ON_SUBSET,
                  # Proven and disproven at the same time will result in
                  # contradictory. The order between those two is irrelevant.
                  ProofStatus::DEFAULT_DISPROVEN_STATUS,
                  ProofStatus::DEFAULT_PROVEN_STATUS,
                  ProofStatus::CONTRADICTORY]

  has_many :proof_attempts, foreign_key: 'sentence_id', dependent: :destroy
  has_many :proof_statuses, through: :proof_attempts
  belongs_to :proof_status

  attr_accessible :state, :state_updated_at, :last_error, :provable

  validates :state, inclusion: {in: State::STATES}

  scope :provable, ->() { where(provable: true) }
  scope :unprovable, ->() { where(provable: false) }

  def update_proof_status!
    reload
    self.proof_status = ordered_proof_statuses.last
    identifiers = proof_statuses.map(&:identifier)
    if identifiers.include?(ProofStatus::DEFAULT_PROVEN_STATUS) &&
      identifiers.include?(ProofStatus::DEFAULT_DISPROVEN_STATUS)
      self.proof_status = ProofStatus.find(ProofStatus::CONTRADICTORY)
    end
    save!
  end

  def prove_options
    hets_options = ontology.hets_options
    Hets::ProveOptions.new(**hets_options.options,
                           ontology: ontology, theorems: [self])
  end

  protected

  def ordered_proof_statuses
    proof_statuses.sort_by { |ps| proof_status_order(ps) }
  end

  def proof_status_order(proof_status)
    if index = STATUS_ORDER.index(proof_status.identifier)
      index
    else
      STATUS_ORDER.index(:any)
    end
  end
end
