$(function(){
  var messages = $(".flash")
  var timeout = null;
  
  var close = function(message){
    message.fadeOut();
  }
  
  messages.hover(function(){
    if(timeout){
      window.clearTimeout(timeout);
      timeout = null;
      
      $(this).append("<button>×</button>").click(function(){
        this.disabled = true;
        close($(this).closest(".flash"));
      })
    }
  })
  
  messages.each(function(){
    var flash = $(this).closest(".flash");
    var words = flash.text().split(" ").length;
    var delay = words < 20 ? 3 : words/4;
    
    timeout = window.setTimeout(function(){
      close(flash);
    }, delay * 1000)
  });
})
