containers    = $(".ontology-version-state")
final_states  = ["done", "failed"]
poll_time = 3000 # milliseconds

return if _.isEmpty(containers) || !containers.length

update = ->
  containers.each ->
    container = $(this)
    current_state = container.data('state')

    $.getJSON container.data('uri') + ".json", (data) ->
      state = data.state

      if state == current_state && !_.contains(final_states, state)
        enqueue()
      else
        current_state = state

        # display the new state
        container
          .attr('class', state)
          .find("span").text(state)

        if state == "pending"
          $(".pending_message").show()
        else
          $(".pending_message").hide()

        if _.contains(final_states, state)
          # replace spinner with refresh button
          container.find(".spinner").
            replaceWith($('<a />').
              attr('href', document.location.href).
              attr('class', 'btn btn-info btn-sm').
              append($('<i />').
                attr('class', 'icon-refresh')).
              text('refresh'))
        else
          enqueue()

enqueue = ->
  setTimeout update, poll_time

enqueue()
