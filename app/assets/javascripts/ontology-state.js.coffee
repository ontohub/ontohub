$ ->
  lastStatus = "pending"
  lastStatus = "downloading"  if $("aside .info .downloading").length > 0
  lastStatus = "processing"  if $("aside .info .processing").length > 0
  updateStatus = ->
    $.getJSON document.location.pathname + ".json", (data) ->
      location.reload()  unless lastStatus is data.state
  
  setInterval updateStatus, 5000  if $("aside .info").find(".pending, .downloading, .processing").length > 0
