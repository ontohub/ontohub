$ ->
  prover_ids = $('#prover-list').find(':checkbox')

  $('#prover-list .select-all').on('click', (e) ->
    prover_ids.prop('checked', true)
  )

  $('#prover-list .select-none').on('click', (e) ->
    prover_ids.prop('checked', false) 
  )
