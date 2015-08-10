module State
  STATES = %w(failed no_result pending fetching processing done)
  TERMINAL_STATES = %w(failed no_result done)

  STATE_LABEL = {
     pending: 'label-warning',
     fetching: 'label-primary',
     processing: 'label-primary',
     done: 'label-success',
     failed: 'label-danger',
     }

  def self.terminal?(state)
    TERMINAL_STATES.include?(state)
  end

  def self.most_successful(states)
    states.sort_by { |s| State.success_order(s) }.last
  end

  def self.success_order(state)
    STATES.index(state)
  end
end
