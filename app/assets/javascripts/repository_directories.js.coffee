$ ->
  if $('#repository_directories_form_line_prototype').length > 0
    clone_and_prepend_to = (source_matcher, target_matcher, callback) ->
      source_el = $($(source_matcher)[0])
      target_el = $($(target_matcher)[0])
      clone_el = source_el.clone()
      clone_el.attr('id', null)
      clone_el.prependTo(target_el)
      callback(clone_el) if callback

    format_error_messages = (error_json) ->
      _.each(error_json, (messages, key) ->
        error_json[key] = _.reduce(messages, (acc, msg) ->
          return acc + msg + "\n"
        , "").trim()
      )

    setup_form_clone = (clone_el) ->
      setup_form_submission_handling(clone_el)
      animateIn(clone_el)

    remove_form_clone = (form_el, callback) ->
      animateOut(form_el, () ->
        form_el.remove()
        callback() if callback
      )

    add_to_table = (directory_link, parent) ->
      directory_el = $(directory_link)
      parent.append(directory_el)
      animateIn(directory_el)

    animateIn = (element) ->
      element.stop(true, true).fadeIn({queue: false}).
        css({display: 'none'}).slideDown()

    animateOut = (element, callback) ->
      element.stop(true, true).fadeOut({queue: false}).slideUp(callback)

    handle_form_submission = (event) ->
      form = $(this)
      values = form.serialize()

      success_callback = (html, text_status, jqXHR) ->
        parent = form.parent()
        remove_form_clone(form, () -> add_to_table(html, parent))

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
