
$.fn.relatizeTimestamps = ->
  $(this).find(".timestamp").each ->
    $this = $(this)
    time = moment($this.text())
    $this.text(time.fromNow()).attr "title", time.format("LLLL")
  this

$ ->
  # relatize all timestamps on load
  $("body").relatizeTimestamps()
