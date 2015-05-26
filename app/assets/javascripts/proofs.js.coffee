$ ->
  $('[data-select]').each(() ->
    checkboxes = $($(this).attr('data-select'))
    check = $(this).attr('data-select-target') == 'all'

    $(this).on('click', (e) ->
      checkboxes.prop('checked', check)
    )
  )
