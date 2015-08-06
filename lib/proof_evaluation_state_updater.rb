class ProofEvaluationStateUpdater
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
    Semaphore.exclusively(theorem.locid) do
      if proof_attempt.state == 'processing'
        theorem.state = 'processing'
      elsif terminal? && all_proof_attempts_terminal?
        failed = failed_proof_attempts
        if failed.any?
          theorem.update_state!(:failed,
                                I18n.t('proof_evaluation_state_updater.failed_proof_attempts',
                                       proof_attempts: failed.map(&:number).join(', ')))
        else
          theorem.update_state!(:done)
        end
      end
    end
  end

  def terminal?
    State::TERMINAL_STATES.include?(state.to_s)
  end

  def all_proof_attempts_terminal?
    !theorem.proof_attempts.state(*State::WORKING_STATES).any?
  end

  def failed_proof_attempts
    theorem.proof_attempts.select(%i(id number)).state(:failed)
  end
end
