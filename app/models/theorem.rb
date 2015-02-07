class Theorem < Sentence
  DEFAULT_STATUS = ProofStatus::DEFAULT_OPEN_STATUS

  has_many :proof_attempts, foreign_key: 'sentence_id'
  belongs_to :proof_status

  # Override Sentence's type: nil scope.
  # Results in duplicate condition in the sql statement.
  default_scope where(type: ['Theorem'])

  before_save :set_default_proof_status

  def set_default_proof_status
    self.proof_status = ProofStatus.find(DEFAULT_STATUS) unless proof_status
  end

  def update_proof_status(proof_status)
    if proof_status.solved? || !self.proof_status.solved?
      self.proof_status = proof_status
      save!
    end
  end

  def to_s
    name
  end
end
