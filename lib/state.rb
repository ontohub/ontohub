module State
  STATES = %w(failed no_result pending fetching processing done)
  TERMINAL_STATES = %w(failed no_result done)

  STATE_LABEL = {
    failed: 'label-danger',
    no_result: 'label-warning',
    pending: 'label-warning',
    fetching: 'label-primary',
    processing: 'label-primary',
    done: 'label-success',
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
