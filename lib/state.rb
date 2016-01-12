module State
  STATES = %w(not_started_yet failed no_result pending fetching processing done)
  TERMINAL_STATES = %w(failed no_result done)
  IDLE_STATES = TERMINAL_STATES + %w(not_started_yet)

  STATE_LABEL = {
    not_started_yet: 'label-default',
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
