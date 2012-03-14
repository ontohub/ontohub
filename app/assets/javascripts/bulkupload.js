$(function(){
  
  var form = $("#bulkupload");
  
  if(!form[0])
    return;
  
  var uploader = {
    form: form,
    
    running: false,
    
    // Pattern to the the URIs
    uriPattern: /(https?:\/\/?\S+)/g,
    
    jobs: [],
    
    created: 0,
    failed: 0,
    remaining: 0,
    
    // Inititialize the Uploader
    init: function(){
      var self = this, form = this.form;
      
      this.uri = form.attr("action");
      this.textarea = form.find("textarea");
      this.actions = form.find("fieldset.actions");
      this.progressbar = form.find(".progressbar");
      this.statusUri = form.find(".status .uri");
      this.statsContainer = form.find(".stats").hide();
      this.showAction('start');
      
      form.submit(function(event){
        event.preventDefault();
        
        if(self.running)
          self.cancel();
        else
          self.run();
      })
    },
    
    // hides all except the given action
    showAction: function(action){
      this.actions.children().each(function(){
        $(this).toggle($(this).hasClass(action));
      })
    },
    
    // extracts URIs from the textarea
    getURIs: function(){
      return this.form.find("textarea").val().match(this.uriPattern);
    },
    
    // Starts the Uploader
    run: function(){
      var uris = this.getURIs();
      
      if(!uris){
        alert("No supported URIs found!")
        return;
      }
      
      this.running = true;
      this.showAction('stop');
      this.statsContainer.show();
      this.initProgress(uris.length);
      this.createJobs(uris);
      this.nextJob();
    },
    
    // Initializes the progressbar
    initProgress: function(max){
      this.updateStats('remaining', max);
      this.progressbar.progressbar({
        max: max
      });
    },
    
    // Updates the progressbar
    updateProgress: function(){
      this.progressbar.progressbar("option", "value", this.created + this.failed);
    },
    
    // create jobs
    createJobs: function(uris){
      var self = this;
      var list = $("<ol class='queue'></ol>");
      
      $.each(uris, function(i,uri){
        var li = $("<li></li>").data('uri', uri).text(uri)
        li.appendTo(list);
        self.jobs.push(li);
      })
      
      this.textarea.replaceWith(list);
    },
    
    // Handler for the cancel button
    cancel: function(){
      this.showAction('restart');
    },
    
    // Mark the uploader as finished
    finished: function(){
      this.cancel();
    },
    
    // is called when the current job is done
    jobDone: function(){
      this.updateStats('remaining',-1);
      this.updateProgress();
      
      if(this.jobs.length > 0)
        this.nextJob()
      else
        this.finished();
    },
    
    // updates the created/failed/remaining counter
    updateStats: function(field, change){
      this[field] += change;
      this.statsContainer.find("."+field).text(this[field]);
    },
    
    // executes the next job
    nextJob: function(){
      var self = this;
      var job = this.jobs.shift();
      var uri = job.data('uri');
      
      // display the current job
      this.statusUri.text(uri);
      
      window.setTimeout(function(){
        $.ajax({
          type: 'POST',
          url: self.uri,
          data: {
            'ontology[uri]': uri,
            'ontology[versions_attributes][0][remote_raw_file_url]': uri
          }
        })
        .success(function(){
          self.updateStats('success',1);
          job.addClass('success');
        })
        .error(function(xhr, status, error){
          self.updateStats('failed',1);
          job.addClass('error').append($("<div class='message'>Foo</div>").text(error));
        })
        .complete(function(){
          self.jobDone();
        })
      },500);
    }
  }
  
  uploader.init();
  
})
