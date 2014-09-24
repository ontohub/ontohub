module State
  STATES = %w(pending fetching processing done failed)
  TERMINAL_STATES = %w(failed done)

  STATE_LABEL = {pending: 'label-warning',
     fetching: 'label-primary',
     processing: 'label-primary',
     done: 'label-success',
     failed: 'label-danger',
     }
end
