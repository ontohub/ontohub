$.widget "ui.remoteCollection",
  options:
    collectionTag: "ol"
    elementTag: "li"
    success: ->

  _create: ->
    self = this
    element = @element
    options = @options
    collection = element.find(options.collectionTag).first()

    # Element created successfully
    element.on "ajax:success", "form", (xhr, data) ->
      newElement = $(data)

      # relatize timestamps, if function is available
      newElement = newElement.relatizeTimestamps()  if $.fn.relatizeTimestamps
      newElement.appendTo(collection).hide().fadeIn "slow"
      self.updateCounter +1
      options.success self.form()

    # Element NOT created, render the returned form
    element.on "ajax:error", "form", (xhr, status, error) ->
      self.form().replaceWith status.responseText

    # Element deleted
    element.on "ajax:success", "a[data-method=delete]", ->

      # find the whole element
      e = $(this).parent()
      e = e.parent()  while e[0] and e.parent()[0] isnt collection[0]
      e.fadeOut ->
        e.remove()

      self.updateCounter -1

  form: ->
    @element.find("form")

  # Updates a <span>-counter in the active ui-tab navigation
  updateCounter: (change) ->
    counter = $("nav.ui-tabs li.ui-tabs-selected span")
    return  unless counter[0]
    count = parseInt(counter.text()) + change
    counter.text count
    if count > 0
      counter.show().effect "highlight", {}, 3000
    else
      counter.hide()
    count
