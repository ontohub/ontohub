class CollectiveProofAttemptWorker < BaseWorker
  sidekiq_options queue: 'hets'

  def self.perform_async(*args)
    perform_async_on_queue('hets', *args)
  end

  # The resource is fetched from the database with klass and id, where
  # klass can be 'Theorem' or 'OntologyVersion'.
  #
  def perform(klass, id, options_and_pa_ids)
    resource = klass.constantize.find(id)
    options_to_attempts_hash = retrieve_options_and_attempts(options_and_pa_ids)
    CollectiveProofAttempt.new(resource, options_to_attempts_hash).run
  end

  protected

  def retrieve_options_and_attempts(options_and_pa_ids)
    result = {}
    options_and_pa_ids.each do |prove_options, pa_ids|
      prove_options = Hets::ProveOptions.from_json(prove_options)
      result[prove_options] = pa_ids.map { |pa_id| ProofAttempt.find(pa_id) }
    end
    result
  end
end
