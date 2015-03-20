class CollectiveProofAttemptWorker < BaseWorker
  sidekiq_options queue: 'hets'

  def self.perform_async(*args)
    perform_async_on_queue('hets', *args)
  end

  # The resource is fetched from the database with klass and id, where
  # klass can be 'Theorem' or 'OntologyVersion'.
  # The provers can be either IDs or names.
  def perform(klass, id, proof_attempts_ids, provers)
    resource = klass.constantize.find(id)
    proof_attempts = proof_attempts_ids.map { |id| ProofAttempt.find(id) }
    CollectiveProofAttempt.new(resource, proof_attempts, provers).run
  end
end
