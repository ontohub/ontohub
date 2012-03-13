$.widget("ui.remoteCollection", {
  options: {
    collectionTag: 'ol',
    elementTag: 'li',
    success: function(){}
  },
  _create: function() {
    var self = this, element = this.element, options = this.options;
    var form = element.find("form");
    var collection = element.find(options.collectionTag).first();
    
    // Element created successfully
    element.on("ajax:success", "form", function(xhr, data){
      
      var newElement = $(data);
      
      // relatize timestamps, if function is available
      if($.fn.relatizeTimestamps)
        newElement = newElement.relatizeTimestamps();
      
      newElement.appendTo(collection).hide().fadeIn('slow');
      
      options.success(form);
    });
    
    // Element NOT created, render the returned form
    element.on("ajax:error", "form", function(xhr, status, error){
      $(this).replaceWith(status.responseText);
    });
    
    // Element deleted
    element.on("ajax:success", "a[data-method=delete]", function(){
      // find the whole element
      var e = $(this).parent();
      while(e[0] && e.parent()[0] != collection[0]){
        e = e.parent();
      }
      
      e.fadeOut(function(){
        e.remove();
      })
    })
  }
});