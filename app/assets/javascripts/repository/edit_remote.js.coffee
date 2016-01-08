$ ->
  if $('#repository_form').length > 0

    to_mirror_option = (previous_option) ->
      previous_option.split("_")[0] + "_r"

    to_non_mirror_option = (previous_option) ->
      if previous_option.split('_')[0] == 'public'
        previous_option
      else
        'private_rw'

    input_access_el    = $('#repository_access')[0]
    source_address_el  = $('#repository_source_address')
    options_non_mirror = _.clone($('#access_options_non_mirror')[0].options)
    options_mirror     = _.clone($('#access_options_mirror')[0].options)

    type_el = $($('#remote_type')[0])

    # If options are not set one by one, the select box wont change.
    set_options = (options, converter, last_value) ->
      input_access_el.options.length = 0
      for option, index in options
        input_access_el.options[index] = option
      $(input_access_el).val(converter(last_value))

    modify_access_list = (mode) ->
      last_value = $(input_access_el).val()
      if mode == 'mirror'
        set_options(options_mirror, to_mirror_option, last_value)
      else
        set_options(options_non_mirror, to_non_mirror_option, last_value)

    is_source_address_set = () ->
      source_address_el.val().trim().length > 0

    was_source_address_set = is_source_address_set()

    reset_was_source_address_set = () ->
      was_source_address_set = is_source_address_set()

    change_options = (event) ->
      if !was_source_address_set && is_source_address_set()
        modify_access_list 'mirror'
      else if was_source_address_set && !is_source_address_set()
        modify_access_list 'non_mirror'
      else if !was_source_address_set && !is_source_address_set()
        modify_access_list 'non_mirror'

    change_type_display = (event) ->
      if !was_source_address_set && is_source_address_set()
        type_el.stop(true,true).fadeIn({queue: false}).css({display: 'none'}).slideDown()
      else if was_source_address_set && !is_source_address_set()
        type_el.stop(true,true).fadeOut({queue: false}).slideUp()
      else if !was_source_address_set && !is_source_address_set()
        type_el.hide()
      else
        type_el.show()

    change_options()
    change_type_display()

    source_address_el.on('input', change_options)
    source_address_el.on('input', change_type_display)
    source_address_el.on('input', reset_was_source_address_set)
  return
