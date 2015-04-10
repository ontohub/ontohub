module ProofAttemptsHelper
  def used_or_configured_prover(proof_attempt)
    proof_attempt.prover || proof_attempt.proof_attempt_configuration.prover
  end
end
