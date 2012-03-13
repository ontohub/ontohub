$(function(){
  var metadata = $(".metadatable");
  
  // Metadata created successfully
  metadata.on("ajax:success", "form", function(xhr, data){
    var form = $(this)
    var metadataListing = form.closest(".metadatable").children("table");
    
    $(data).appendTo(metadataListing).hide().fadeIn('slow');
    form.find("fieldset.inputs input").val("").first().focus();
  })
  
  // Metadata NOT created, render the returned form
  metadata.on("ajax:error", "form", function(xhr, status, error){
    $(this).replaceWith(status.responseText);
  })
  
  // Metadata deleted
  metadata.on("ajax:success", "a[data-method=delete]", function(){
    var li = $(this).closest(".actions").closest("li");
    li.fadeOut(function(){
      li.remove();
    })
  })
  
});
