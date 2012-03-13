
$(function(){
  $(".comments").remoteCollection({
    collectionTag: 'ol',
    elementTag: 'li',
    success: function(form){
      form.html("Thanks for your comment.");
    }
  });
  
});
