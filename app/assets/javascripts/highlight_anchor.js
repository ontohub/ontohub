/**
 * Highlights the anchors parent if the location contains a fragment.
 * 
 * /path#comment_15 -> will highlight parent of <a name="comment_15">
 * 
 */
$(function(){
  var hash = document.location.hash;
  if (hash) {
    $("a[name="+hash.substr(1)+"]").parent().effect("highlight", {}, 3000);
  }
})