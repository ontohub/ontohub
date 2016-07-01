class ProofEvaluationStateUpdater
  MUTEX_EXPIRATION = 2.minutes

  attr_reader :proof_attempt, :state, :message, :theorem

  def initialize(proof_attempt, state, message = nil)
    @proof_attempt = proof_attempt
    @state = state.to_sym
    @message = message
    @theorem = proof_attempt.theorem
  end

  def call
    proof_attempt.update_state!(state, message)
    update_theorem_state
  end

  def update_theorem_state
    Semaphore.exclusively(theorem.locid, expiration: MUTEX_EXPIRATION) do
      theorem_message = nil
      theorem_state = State.
        most_successful(theorem.proof_attempts.select(:state).map(&:state))
      if theorem_state == 'failed'
        theorem_message =
          I18n.t('proof_evaluation_state_updater.failed_proof_attempts',
                 proof_attempts: failed_proof_attempts.map(&:number).join(', '))
      end
      theorem.update_state!(theorem_state, theorem_message)
    end
  end

  def failed_proof_attempts
    theorem.proof_attempts.select(%i(id number)).state(:failed)
  end
end
