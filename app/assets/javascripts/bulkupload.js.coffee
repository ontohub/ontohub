$ ->
  form = $("#bulkupload")
  return unless form[0]

  uploader =
    form: form
    running: false

    # Pattern to the the URIs
    uriPattern: /(https?:\/\/?\S+)/g
    jobs: []
    created: 0
    failed: 0
    remaining: 0

    # Inititialize the Uploader
    init: ->
      self = this
      form = @form
      @uri = form.attr("action")
      @textarea = form.find("textarea")
      @actions = form.find("fieldset.actions")
      @progressbar = form.find(".progressbar")
      @statusUri = form.find(".status .uri")
      @statsContainer = form.find(".stats").hide()
      @showAction "start"
      form.submit (event) ->
        event.preventDefault()
        if self.running
          self.cancel()
        else
          self.run()

    # hides all except the given action
    showAction: (action) ->
      @actions.children().each ->
        $(this).toggle $(this).hasClass(action)

    # extracts URIs from the textarea
    getURIs: ->
      @form.find("textarea").val().match @uriPattern

    # Starts the Uploader
    run: ->
      uris = @getURIs()
      unless uris
        alert "No supported URIs found!"
        return
      @running = true
      @showAction "stop"
      @statsContainer.show()
      @initProgress uris.length
      @createJobs uris
      @nextJob()

    # Initializes the progressbar
    initProgress: (max) ->
      @updateStats "remaining", max
      @progressbar.progressbar max: max

    # Updates the progressbar
    updateProgress: ->
      @progressbar.progressbar "option", "value", @created + @failed

    # create jobs
    createJobs: (uris) ->
      self = this
      list = $("<ol class='queue'></ol>")
      $.each uris, (i, uri) ->
        li = $("<li></li>").data("uri", uri).text(uri)
        li.appendTo list
        self.jobs.push li

      @textarea.replaceWith list

    # Handler for the cancel button
    cancel: ->
      @showAction "restart"

    # Mark the uploader as finished
    finished: ->
      @cancel()

    # is called when the current job is done
    jobDone: ->
      @updateStats "remaining", -1
      @updateProgress()
      if @jobs.length > 0
        @nextJob()
      else
        @finished()

    # updates the created/failed/remaining counter
    updateStats: (field, change) ->
      this[field] += change
      @statsContainer.find("." + field + " .count").text this[field]

    # executes the next job
    nextJob: ->
      self = this
      job = @jobs.shift()
      uri = job.data("uri")

      # display the current job
      @statusUri.text uri
      window.setTimeout (->
        $.ajax(
          type: "POST"
          url: self.uri
          data:
            "ontology[iri]": uri
            "ontology[versions_attributes][0][source_url]": uri
          format: "json"
        ).success(->
          self.updateStats "created", 1
          job.addClass "success"
        ).error((xhr, status, error) ->
          self.updateStats "failed", 1
          message = $("<ul class='errors'></ul>")
          if xhr.getResponseHeader("Content-Type").indexOf("application/json") is 0
            $.each $.parseJSON(xhr.responseText).errors, (attr, errors) ->
              $("<li></li>").text(attr + " " + errors).appendTo message
          else
            $("<li></li>").text(error).appendTo message
          job.addClass("error").append message
        ).complete ->
          self.jobDone()
      ), 500

  uploader.init()
