container    = $("#ontology-state")
currentState = container.attr('class')
finalStates  = ["done", "failed"]

return if !currentState || $.inArray(currentState, finalStates) != -1

uri = container.data('uri')

update = ->
  $.getJSON container.data('uri') + ".json", (data) ->
    state = data.state

    if state == currentState
      enqueue()
    else
      currentState = state

      # display the new state
      container
      .attr('class', state)
      .find("span").text(state)

      if state != "pending"
        $(".pending_message").hide()

      if $.inArray(state, finalStates) != -1
        # replace spinner with refresh button
        container.find(".spinner").replaceWith("<a href='#{uri}' class='btn btn-info'><i class='icon-refresh'></i> refresh</a>")
      else
        enqueue()

enqueue = ->
  setTimeout update, 3000

enqueue()
