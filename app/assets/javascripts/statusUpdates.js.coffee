container    = $(".state")
finalStates  = ["done", "failed"]
states       = ["done", "failed", "pending"]



update = ->
  container.each ->

    uri = $(this).data('uri')
    reload_uri = container.data('reload_uri')
    button = container.data('button')
    classes = container.attr('class')
    currentState = $.grep(classes.split(' '), (element, index) ->
        $.inArray(element, states) != -1
      )
    return if !currentState || $.inArray(currentState, finalStates) != -1
    $.getJSON container.data('uri'), (data) ->

      state = data.state
      if state == currentState
        enqueue()
      else
        currentState = state

        # display the new state
        container
        .attr('class', state)
        .find("span").find("span").text(state)

        if $.inArray(state, finalStates) != -1
          # replace spinner with refresh button
          container.find(".spinner").replaceWith("<a href='#{reload_uri}' class='btn btn-info'><i class='icon-refresh'></i> #{button}</a>")
        else
          enqueue()

enqueue = ->
  setTimeout update, 3000

enqueue()
