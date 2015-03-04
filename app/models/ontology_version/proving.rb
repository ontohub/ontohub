module OntologyVersion::Proving

  extend ActiveSupport::Concern
  include Hets::ErrorHandling

  included do
    @queue = 'hets'
  end

  def async_prove(*args)
    async :prove
  end

  def prove
    update_state! :processing

    do_or_set_failed do
      cmd, input_io = execute_proof
      return if cmd == :abort

      ontology.import_proof(self, self.user, input_io)
      update_state! :done
    end
  end

  def unproven_theorems
    ontology.theorems.where(proof_status_id: Theorem::DEFAULT_STATUS)
  end

  # generate XML by passing the raw ontology to Hets
  def execute_proof
    input_io = Hets.prove_via_api(ontology, ontology.repository.url_maps)
    [:all_is_well, input_io]
  rescue Hets::ExecutionError => e
    handle_hets_execution_error(e, self)
    [:abort, nil]
  end
end
