$.widget "ui.relationList",
  _create: ->
    self = this
    element = @element
    @association = element.data("association")
    @scope = element.data("scope").split(",")
    @polymorphic = element.data("polymorphic")
    @model = @toUnderscore(element.data("model"))

    # Attach Autocomplete to inputs
    @autocomplete = element.find("input.autocomplete")
    @autocomplete.autocomplete(
      minLength: 3
      source: (request, response) ->
        self.autocompleteSource request, response
      select: (event, ui) ->
        self.autocompleteSelect event, ui
    ).data("uiAutocomplete")._renderItem = @autocompleteIcon

    # Never submit the autocompletion form
    element.on "submit", "form.add", (event) ->
      event.preventDefault()

    # Removal of relations
    element.on "click", "a[rel=delete]", (event) ->
      event.preventDefault()
      li = $(this).closest("li")
      return  unless confirm("really delete?")
      $.ajax
        type: "POST"
        url: li.data("uri")
        data:
          _method: "delete"
        success: ->
          li.fadeOut ->
            li.remove()
        error: (xhr, status, error) ->
          li.trigger "ajax:error", [xhr, status, error]

    # Show / Hide edit form
    element.on "click", "a[rel=edit]", (event) ->
      event.preventDefault()
      @blur()
      li = $(this).closest("li")
      form = li.find("form")
      if form.size() is 0

        # show form
        random = Math.random().toString().split(".")[1]

        # clone template form
        form = element.find("form.editTemplate").clone().wrap("<div></div>").parent().html()
        form = $(form.replace(/%RANDOM%/g, random)).removeClass("editTemplate").addClass("edit").attr("action", li.data("uri")).appendTo(li)

        # extend selector for more supported elements
        form.find("input[type=checkbox], select").each ->
          name = $(this).attr("name")
          return  unless name

          # change 'model[name]' into 'name'
          match = name.match(/\w+\[(\w+)\]/)
          name = match[1]  if match
          value = li.data(name)
          type = @tagName.toLowerCase()
          type = @type.toLowerCase()  if type is "input"
          switch type
            when "checkbox"
              @checked = value is "1"
            when "select"
              $(this).val value

      # add here support for other input types, when needed
      else

        # hide form
        form.remove()

    # Removal of related object succeeded
    element.on "ajax:success", "ul", (event, data) ->
      target = $(event.target)
      li = target.closest("li")
      li.replaceWith data

    # AJAX Actions failed
    element.on "ajax:error", (xhr, status, error) ->
      alert status.responseText

  # collects elements from list for exclusion
  excludeMap: ->
    self = this
    map = {}
    @element.find("ul").children().each ->
      $this = $(this)
      type = $this.data("type") or self.scope[0]
      key = "exclude[" + type + "]"
      id = $this.data("id")
      if map[key]
        map[key] += "," + id
      else
        map[key] = id
    map

  # source for autcomplete
  autocompleteSource: (request, response) ->
    params = $.extend(@excludeMap(),
      term: request.term
      scope: @scope.join(",")
    )
    $.ajax
      url: "/autocomplete"
      data: params
      success: (data) ->
        response data

  # autocomplete select-handler
  autocompleteSelect: (event, ui) ->
    input = $(this)
    list = @element.find("ul")
    params = {}
    params[@model + "[" + @association + "_id]"] = ui.item.id
    params[@model + "[" + @association + "_type]"] = ui.item.type  if @polymorphic

    # Create the relation
    $.post @element.data("uri"), params, (data) ->
      data = $(data).hide()
      list.append data
      data.fadeIn "slow"

    @autocomplete.val ""
    false

  autocompleteIcon: (ul, item) ->
    $("<li></li>").data("ui-autocomplete-item", item).append("<a data-type='" + item.type + "'>" + item.label + "</a>").appendTo ul

  # camelCase to under_score
  toUnderscore: (value) ->
    value = value.replace(/([A-Z])/g, ($1) ->
      "_" + $1.toLowerCase()
    )
    value = value.substr(1)  if value.indexOf("_") is 0
    value
