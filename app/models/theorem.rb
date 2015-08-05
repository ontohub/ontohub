class Theorem < Sentence
  include StateUpdater

  DEFAULT_STATUS = ProofStatus::DEFAULT_OPEN_STATUS

  has_many :proof_attempts, foreign_key: 'sentence_id', dependent: :destroy
  belongs_to :proof_status

  attr_accessible :state, :state_updated_at, :last_error, :provable

  validates :state, inclusion: {in: State::STATES}

  before_validation :set_default_state
  before_save :set_default_proof_status

  scope :provable, ->() { where(provable: true) }
  scope :unprovable, ->() { where(provable: false) }

  def set_default_state
    self.state ||= 'pending'
  end

  def set_default_proof_status
    self.proof_status = ProofStatus.find(DEFAULT_STATUS) unless proof_status
  end

  def update_proof_status(proof_status)
    if proof_status.solved? || !self.proof_status.solved?
      self.proof_status = proof_status
      save!
    end
  end

  def prove_options
    hets_options = ontology.hets_options
    Hets::ProveOptions.new(**hets_options.options,
                           ontology: ontology, theorems: [self])
  end
end
