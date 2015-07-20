$ ->
  # select all / select none buttons
  $('[data-select]').each(() ->
    checkboxes = $($(this).attr('data-select'))
    check = $(this).attr('data-select-target') == 'all'

    $(this).on('click', (e) ->
      checkboxes.prop('checked', check)
    )
  )


  # axiom selection method show / hide sections
  radio_buttons_selector = '[name="proof[axiom_selection_method]"]'
  previously_checked_value = $(radio_buttons_selector + ':checked').attr('value')
  radio_buttons = $(radio_buttons_selector)

  animate_in = (el) ->
    $(el).stop(true,true).fadeIn({queue: false}).css({display: 'none'}).slideDown()

  animate_out = (el) ->
    $(el).stop(true,true).fadeOut({queue: false}).slideUp()

  hide_unselected_sections = () ->
    radio_buttons.filter((radio_button) ->
      $(this).attr('value') != previously_checked_value
    ).each(() ->
      value = $(this).attr('value')
      animate_out($('#' + value))
    )

  switch_shown_section = (radio_button) ->
    checked_value = $(radio_button).attr('value')
    animate_out('#' + previously_checked_value)
    animate_in('#' + checked_value)
    previously_checked_value = checked_value

  hide_unselected_sections()
  radio_buttons.on('change', (e) ->
    switch_shown_section(this)
  )
