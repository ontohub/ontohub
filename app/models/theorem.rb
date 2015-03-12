class Theorem < Sentence
  DEFAULT_STATUS = ProofStatus::DEFAULT_OPEN_STATUS

  has_many :proof_attempts, foreign_key: 'sentence_id', dependent: :destroy
  belongs_to :proof_status

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

  def async_prove(*_args)
    async :prove
  end

  def prove
    ontology_version = ontology.current_version
    ontology_version.update_state! :processing

    ontology_version.do_or_set_failed do
      cmd, input_io = execute_proof
      return if cmd == :abort

      ontology.import_proof(ontology_version, ontology_version.user, input_io)
      ontology_version.update_state! :done
    end
  end

  def execute_proof
    hets_options =
      Hets::ProveOptions.new(:'url-catalog' => ontology.repository.url_maps,
                             ontology: ontology,
                             theorems: [self])
    input_io = Hets.prove_via_api(ontology, hets_options)
    [:all_is_well, input_io]
  rescue Hets::ExecutionError => e
    handle_hets_execution_error(e, self)
    [:abort, nil]
  end
end
