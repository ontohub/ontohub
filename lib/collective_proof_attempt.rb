class CollectiveProofAttempt
  attr_accessor :resource, :options_to_attempts_hash

  # Resource can be a Theorem or an OntologyVersion.
  def initialize(resource, options_to_attempts_hash)
    self.resource = resource
    self.options_to_attempts_hash = options_to_attempts_hash
  end

  def run
    ontology_version.update_state!(:processing)
    ontology_version.do_or_set_failed do
      if theorem?
        resource.update_state!(:processing)
        resource.do_or_set_failed do
          run_body
          resource.update_state!(:done)
        end
      else
        resource.theorems.each { |theorem| theorem.update_state!(:processing) }
        run_body
        resource.theorems.each { |theorem| theorem.update_state!(:done) }
      end
      ontology_version.update_state!(:done)
    end
  end

  protected

  def theorem?
    resource.is_a?(Theorem)
  end

  def ontology_version
    @ontology_version ||=
      if theorem?
        resource.ontology.current_version
      else
        resource
      end
  end

  def ontology
    @ontology ||= ontology_version.ontology
  end

  def run_body
    options_to_attempts_hash.each do |prove_options, proof_attempts|
      prove_options.merge!(resource.prove_options)
      prove(prove_options, proof_attempts)
    end
  end

  def prove(prove_options, proof_attempts)
    proof_attempts.each { |pa| pa.update_state!(:processing) }
    cmd, input_io = execute_proof(prove_options)
    return if cmd == :abort

    ontology.import_proof(ontology_version,
                          ontology_version.user,
                          proof_attempts,
                          input_io)
  end

  def execute_proof(prove_options)
    input_io = Hets.prove_via_api(ontology, prove_options)
    [:all_is_well, input_io]
  rescue Hets::ExecutionError => e
    handle_hets_execution_error(e, self)
    [:abort, nil]
  end
end
