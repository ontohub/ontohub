
$("table.entities").on 'click', 'td:first-child a', (event) ->
  event.preventDefault()
  $(this).closest("tr").next().next().toggle()
  
$("#oops-state").on 'click', 'a.pitfalls', (event) ->
  event.preventDefault()
  $('div.pitfalls').toggle()

container    = $("#oops-state")
currentState = container.attr('class')
finalStates  = ["done", "failed"]

return if !currentState || $.inArray(currentState, finalStates) != -1

uri = container.data('uri')

update = ->
  $.getJSON container.data('uri')  + '/oops_state', (data) ->
    state = data.state
    
    if state == currentState
      enqueue()
    else
      currentState = state
      
      # display the new state
      container
      .attr('class', state)
      .find("span").text(state)
      
      if $.inArray(state, finalStates) != -1
        # replace spinner with refresh button
        container.find(".spinner").replaceWith("<a href='#{uri}' class='btn btn-info'><i class='icon-refresh'></i> show results</a>")
      else
        enqueue()

enqueue = ->
  setTimeout update, 3000

enqueue()
