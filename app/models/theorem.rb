class Theorem < Sentence
  DEFAULT_STATUS = 'OPN'

  has_many :proof_attempts, foreign_key: 'sentence_id'

  # Override Sentence's type: nil scope.
  # Results in duplicate condition in the sql statement.
  default_scope where(type: ['Theorem'])

  before_save :set_default_proof_status

  attr_accessible :proof_status

  validates_inclusion_of :proof_status, in: ProofAttempt::STATUSES

  def set_default_proof_status
    self.proof_status = DEFAULT_STATUS unless proof_status
  end

  def update_proof_status(proof_status)
    if ProofAttempt.decisive_status?(proof_status) ||
      !ProofAttempt.decisive_status?(self.proof_status)
      self.proof_status = proof_status
      save
    end
  end

end
