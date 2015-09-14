class Theorem < Sentence
  include StateUpdater

  has_many :proof_attempts, foreign_key: 'sentence_id', dependent: :destroy
  belongs_to :proof_status

  attr_accessible :state, :state_updated_at, :last_error, :provable

  validates :state, inclusion: {in: State::STATES}

  scope :provable, ->() { where(provable: true) }
  scope :unprovable, ->() { where(provable: false) }

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
