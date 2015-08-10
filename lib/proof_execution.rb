class ProofExecution
  attr_accessor :proof_attempt, :prove_options

  delegate :theorem, :proof_attempt_configuration, to: :proof_attempt
  delegate :ontology, to: :theorem

  def initialize(proof_attempt)
    self.proof_attempt = proof_attempt
  end

  def call
    prepare_axiom_selection
    prepare_prove_options
    prove
  end

  protected

  def prepare_axiom_selection
    proof_attempt_configuration.axiom_selection.specific.call
  end

  def prepare_prove_options
    self.prove_options = proof_attempt.proof_attempt_configuration.prove_options
    prove_options.merge!(theorem.prove_options)
  end

  def prove
    proof_attempt.update_state!(:processing)
    cmd, input_io = execute_proof(prove_options)
    return if cmd == :abort

    ontology.import_proof(ontology_version,
                          ontology_version.user,
                          proof_attempt,
                          input_io)
  end

  def execute_proof(prove_options)
    input_io = Hets.prove_via_api(ontology, prove_options)
    [:all_is_well, input_io]
  end

  def ontology_version
    ontology.current_version
  end
end
