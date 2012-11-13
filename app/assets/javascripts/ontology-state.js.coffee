$ ->
  lastStatus = "pending"
  lastStatus = "downloading"  if $(".downloading").length > 0
  lastStatus = "processing"  if $(".processing").length > 0
  updateStatus = ->
    $.getJSON document.location.pathname + ".json", (data) ->
      window.location = location.href.split("?")[0] unless lastStatus is data.state
  
  setInterval updateStatus, 5000  if $("#status").find(".pending, .downloading, .processing").length > 0
