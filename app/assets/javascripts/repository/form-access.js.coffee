$ ->
  if $('#repository_form').length > 0
    mirror_option        = (o)     -> o.value.search(/_rw/) == -1
    to_mirror_option     = (value) -> value.split("_")[0] + "_r"
    to_non_mirror_option = (value) -> value

    input_access_el    = $('#repository_form #repository_access')[0]
    source_address_el  = $('#repository_form #repository_source_address')
    options_all        = input_access_el.options
    options_non_mirror = _.clone(options_all)
    options_mirror     = _.filter(options_all, mirror_option)

    # If options are not set one by one, the select box won't change.
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
    change_options = (event) ->
      if !was_source_address_set && is_source_address_set()
        modify_access_list 'mirror'
      else if was_source_address_set && !is_source_address_set()
        modify_access_list 'non_mirror'
      else if !was_source_address_set && !is_source_address_set()
        modify_access_list 'non_mirror'

    change_options()

    source_address_el.on('change', change_options)
  return
