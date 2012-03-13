$(function(){
  var comments = $(".comments");
  
  // Comment created successfully
  comments.on("ajax:success", "form", function(xhr, data){
    var form = $(this)
    var commentsListing = form.closest(".comments").children("ol");
    
    $(data).appendTo(commentsListing).hide().fadeIn('slow');
    form.html("Thanks for your comment.");
  })
  
  // Comment NOT created, render the returned form
  comments.on("ajax:error", "form", function(xhr, status, error){
    $(this).replaceWith(status.responseText);
  })
  
  // Comment deleted
  comments.on("ajax:success", "a[data-method=delete]", function(){
    var li = $(this).closest(".actions").closest("li");
    li.fadeOut(function(){
      li.remove();
    })
  })
  
});
