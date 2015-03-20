class Theorem < Sentence
  include StateUpdater

  DEFAULT_STATUS = ProofStatus::DEFAULT_OPEN_STATUS

  has_many :proof_attempts, foreign_key: 'sentence_id', dependent: :destroy
  belongs_to :proof_status

  attr_accessible :state, :state_updated_at, :last_error

  validates :state, inclusion: {in: State::STATES}

  before_validation :set_default_state
  before_save :set_default_proof_status

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

  def async_prove(prove_options = nil)
    async :prove, prove_options
  end

  def prove(prove_options = nil)
    ontology_version = ontology.current_version
    ontology_version.update_state! :processing

    ontology_version.do_or_set_failed do
      cmd, input_io = execute_proof(prepared_prove_options(prove_options))
      return if cmd == :abort

      ontology.import_proof(ontology_version, ontology_version.user, input_io)
      ontology_version.update_state! :done
    end
  end

  def prepared_prove_options(prove_options = nil)
    prove_options ||= Hets::ProveOptions.new
    # If the prove_options have gone through the async_prove call, they are now
    # a Hash and need to be restored as a ProveOptions object.
    if prove_options.is_a?(Hash)
      prove_options = Hets::ProveOptions.from_hash(prove_options)
    end
    prove_options.add(:'url-catalog' => ontology.repository.url_maps,
                      ontology: ontology,
                      theorems: [self])
    prove_options
  end

  def execute_proof(prove_options)
    input_io = Hets.prove_via_api(ontology, prove_options)
    [:all_is_well, input_io]
  rescue Hets::ExecutionError => e
    handle_hets_execution_error(e, self)
    [:abort, nil]
  end
end
