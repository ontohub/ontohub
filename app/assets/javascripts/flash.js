$(function(){
  $(".flash").each(function(){
    var flash = $(this).closest(".flash");
    var words = flash.text().split(" ").length;
    var delay = words < 20 ? 3 : words/4;
    
    window.setTimeout(function(){
      flash.fadeOut();
    }, delay * 1000)
  });
})
