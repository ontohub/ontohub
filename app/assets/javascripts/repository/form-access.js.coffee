$ ->
  if $('#repository_form').length > 0
    mirror_option = (o) -> o.value.search(/_rw/) == -1
    non_mirror_option = (o) -> true
    to_mirror_option = (value) -> value.split("_")[0] + "_r"
    to_non_mirror_option = (value) -> value

    input_access_el = $('#repository_form #repository_access')[0]
    source_address_el = $('#repository_form #repository_source_address')
    options_all = input_access_el.options
    options_mirror = []

    for o in options_all
      options_mirror.push o if mirror_option(o)

    options_non_mirror = []
    for o in options_all
      options_non_mirror.push o if non_mirror_option(o)

    modify_access_list = (mode) ->
      last_value = $(input_access_el).val()
      input_access_el.options.length = 0
      if mode == 'mirror'
        for i in [0..options_mirror.length-1]
          input_access_el.options[i] = options_mirror[i]
        $(input_access_el).val(to_mirror_option(last_value))
      else
        for i in [0..options_non_mirror.length-1]
          input_access_el.options[i] = options_non_mirror[i]
        $(input_access_el).val(to_non_mirror_option(last_value))

    is_source_address_set = () ->
      source_address_el.val().trim().length > 0

    was_source_address_set = is_source_address_set()
    change_options = (event) ->
      if is_source_address_set() && !was_source_address_set
        modify_access_list 'mirror'
      else if was_source_address_set && !is_source_address_set()
        modify_access_list 'non_mirror'
      else if !was_source_address_set && !is_source_address_set()
        modify_access_list 'non_mirror'

    change_options()

    source_address_el.on('change', change_options)
  return
