$ ->
  if $('#repository_directories_form_line_prototype').length > 0
    clone_element = (source_matcher) ->
      source_el = $($(source_matcher)[0])
      clone_el = source_el.clone()
      clone_el.attr('id', null)
      clone_el

    clone_and_prepend_to = (source_matcher, target_matcher, callback) ->
      target_el = $($(target_matcher)[0])
      clone_el = clone_element(source_matcher)
      clone_el.prependTo(target_el)
      callback(clone_el) if callback

    setup_form_clone = (clone_el) ->
      setup_form_submission_handling(clone_el)
      animateIn(clone_el)
      $('input[name="repository_directory[name]"]', clone_el).focus()

    remove_form_clone = (remove_el, callback) ->
      animateOut(remove_el, () ->
        remove_el.remove()
        callback() if callback
      )

    add_to_table = (link_el) ->
      table = $('#directory-listing')
      table.prepend(link_el)
      animateIn(link_el)

    animateIn = (element) ->
      element.stop(true, true).fadeIn({queue: false}).
        css({display: 'none'}).slideDown()

    animateOut = (element, callback) ->
      element.stop(true, true).fadeOut({queue: false}).slideUp(callback)

    remove_empty_repository_hint = () ->
      hint_line = $('#empty_repository_hint')
      animateOut(hint_line)

    show_flash_message = (message) ->
      flash_messages_el = $('.flash-messages')
      flash_prototype_el = $('#repository_directories_flash_message_prototype')
      clone_and_prepend_to(flash_prototype_el, flash_messages_el, (clone_el) ->
          clone_el.append(message)
        )

    directory_link = (link) ->
      line_el = clone_element('#repository_directories_line_prototype')
      anchor_el = $('a', line_el)
      anchor_el.attr('href', link.url)
      anchor_el.html(link.text)
      console.log(line_el)
      line_el

    handle_form_submission = (event) ->
      form = $(this)
      values = form.serialize()

      success_callback = (json, text_status, jqXHR) ->
        html = json.html
        form_tr = form.parent().parent()
        remove_form_clone(form_tr, () -> add_to_table(directory_link(json.link)))
        remove_empty_repository_hint()
        show_flash_message(json.text)

      error_callback = (jqXHR) ->
        form.html(jqXHR.responseText)

      $.ajax({
        type: 'POST'
        url: $(this).attr('action'),
        data: values,
        success: success_callback,
        error: error_callback
      })

      # Return false to prevent sending the form.
      # For some reason event.preventDefault() does not work.
      false

    setup_form_submission_handling = (form_parent_el) ->
      form_el = $('form', $(form_parent_el))
      form_el.unbind('submit').submit(handle_form_submission)

    form_prototype_el = $($('#repository_directories_form_line_prototype')[0])
    setup_form_submission_handling(form_prototype_el)

    btn_create_el = $('#create_subdirectory')
    btn_create_el.click(() -> clone_and_prepend_to(
      form_prototype_el, form_prototype_el.parent(), setup_form_clone))
