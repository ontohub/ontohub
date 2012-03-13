$(function(){
  var comments = $(".comments");
  
  comments.find("form")
  // Comment created successfully
  .on("ajax:success", function(xhr, data){
    var form = $(this)
    var commentsListing = form.closest(".comments").children("ol");
    
    $(data).appendTo(commentsListing).hide().fadeIn('slow');
    form.html("Thanks for your comment.");
  })
  // Comment NOT created, render the returned form
  .on("ajax:error", function(xhr, status, error){
    $(this).replaceWith(status.responseText);
  })
  
  // Comment deleted
  comments.find("ol").on("ajax:success", "a[data-method=delete]", function(){
    var li = $(this).closest(".actions").closest("li");
    li.fadeOut(function(){
      li.remove();
    })
  })
  
});