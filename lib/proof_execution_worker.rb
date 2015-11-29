class ProofExecutionWorker < BaseWorker
  sidekiq_options queue: 'hets', retry: false

  def perform(proof_attempt_id)
    proof_attempt = ProofAttempt.find(proof_attempt_id)
    ProofExecution.new(proof_attempt).call
  end
end
