
$("table.entities").on 'click', 'td:first-child a', (event) ->
  event.preventDefault()
  $(this).closest("tr").next().next().toggle()
  
$("p.oops").on 'click', 'a.pitfalls', (event) ->
  event.preventDefault()
  $('div.pitfalls').toggle()
