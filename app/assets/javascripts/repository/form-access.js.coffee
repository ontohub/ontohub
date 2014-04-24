$ ->
  if $('#repository_form').length > 0
    mirror_option = (o) -> o.value.search(/_rw/) == -1
    non_mirror_option = (o) -> true

    window.input_access = $('#repository_form #repository_access')[0]
    window.source_address = $('#repository_form #repository_source_address')[0]
    window.options_all = window.input_access.options
    window.options_mirror = []

    for o in window.options_all
      window.options_mirror.push o if mirror_option(o)

    window.options_non_mirror = []
    for o in window.options_all
      window.options_non_mirror.push o if non_mirror_option(o)

    modify_access_list = (mode) ->
      window.input_access.options.length = 0
      if mode == 'mirror'
        for i in [0..window.options_mirror.length-1]
          window.input_access.options[i] = window.options_mirror[i]
      else
        for i in [0..window.options_non_mirror.length-1]
          window.input_access.options[i] = window.options_non_mirror[i]

    is_source_address_set = () ->
      window.source_address.value.trim().length > 0

    window.was_source_address_set = is_source_address_set()
    change_options = (event) ->
      if is_source_address_set() && !window.was_source_address_set
        modify_access_list 'mirror'
      else if window.was_source_address_set && !is_source_address_set()
        modify_access_list 'non_mirror'
      else if !window.was_source_address_set && !is_source_address_set()
        modify_access_list 'non_mirror'

    change_options()

    console.log(change_options)
    console.log(typeof change_options)
    # TODO: find out why change_options is undefined
    window.source_address.value.change(change_options)
  return
