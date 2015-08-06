module State
  STATES = %w(pending fetching processing done failed)
  TERMINAL_STATES = %w(done failed)
  WORKING_STATES = STATES - TERMINAL_STATES

  STATE_LABEL = {
     pending: 'label-warning',
     fetching: 'label-primary',
     processing: 'label-primary',
     done: 'label-success',
     failed: 'label-danger',
     }

  def self.working?(state)
    WORKING_STATES.include?(state)
  end

  def self.terminal?(state)
    TERMINAL_STATES.include?(state)
  end
end
