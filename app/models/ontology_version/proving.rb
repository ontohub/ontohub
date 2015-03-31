module OntologyVersion::Proving
  extend ActiveSupport::Concern
  include Hets::ErrorHandling

  included do
    @queue = 'hets'
  end

  def async_prove(prove_options = nil)
    async :prove, prove_options
  end

  def prove(prove_options = nil)
    update_state! :processing

    do_or_set_failed do
      cmd, input_io = execute_proof(prepared_prove_options(prove_options))
      return if cmd == :abort

      ontology.import_proof(self, user, input_io)
      update_state! :done
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
                      ontology: ontology)
    prove_options
  end

  # generate XML by passing the raw ontology to Hets
  def execute_proof(prove_options)
    input_io = Hets.prove_via_api(ontology, prove_options)
    [:all_is_well, input_io]
  rescue Hets::ExecutionError => e
    handle_hets_execution_error(e, self)
    [:abort, nil]
  end
end
