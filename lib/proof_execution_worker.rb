class ProofExecutionWorker < BaseWorker
  sidekiq_options queue: 'hets'

  def self.perform_async(*args)
    perform_async_on_queue('hets', *args)
  end

  def perform(proof_attempt_id)
    proof_attempt = ProofAttempt.find(proof_attempt_id)
    ProofExecution.new(proof_attempt).call
  end
end
