# 
# Bootstrap tooltip
# 
$ ->
  $("button.help").tooltip(placement: "right").click (event) ->
    event.preventDefault()
    $(this).closest("form").find("input:visible").first().focus()

  $("aside .info .error .help").tooltip placement: "bottom"
  $("ul.formats a[title]").tooltip placement: "bottom"
  $("span.entity_tooltip").tooltip placement: "right"
  $(".iri").tooltip()
  $(".tooltip-btn").tooltip()
