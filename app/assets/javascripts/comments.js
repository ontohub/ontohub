$(".comments form")
.on("ajax:success", function(xhr, data){
  var form = $(this)
  var commentsListing = form.closest(".comments").children("ol");
  
  $(data).appendTo(commentsListing).hide().fadeIn('slow', function(){
    form.html();
  });
})
.on("ajax:error", function(xhr, status, error){
  $(this).replaceWith(status.responseText);
})
