class CollectiveProofAttempt
  attr_accessor :resource, :options_to_attempts_hash

  # Resource can be a Theorem or an OntologyVersion.
  def initialize(resource, options_to_attempts_hash)
    self.resource = resource
    self.options_to_attempts_hash = options_to_attempts_hash
  end

  def run
    ontology_version.update_state! :processing
    options_to_attempts_hash.each do |prove_options, proof_attempts|
      prove_options.merge!(resource.prepared_prove_options)
      prove(prove_options, proof_attempts)
    end
  end

  protected

  def ontology_version
    @ontology_version ||=
      if resource.is_a?(Theorem)
        resource.ontology.current_version
      else
        resource
      end
  end

  def ontology
    @ontology ||= ontology_version.ontology
  end

  def prove(prove_options, proof_attempts)
    ontology_version.update_state! :processing
    ontology_version.do_or_set_failed do
      cmd, input_io = execute_proof(prove_options)
      return if cmd == :abort

      ontology.import_proof(ontology_version, ontology_version.user, input_io)
      ontology_version.update_state! :done
    end
  end

  def execute_proof(prove_options)
    input_io = Hets.prove_via_api(ontology, prove_options)
    [:all_is_well, input_io]
  rescue Hets::ExecutionError => e
    handle_hets_execution_error(e, self)
    [:abort, nil]
  end
end
