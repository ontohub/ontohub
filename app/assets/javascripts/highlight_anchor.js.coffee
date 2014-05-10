#
# Highlights the anchors parent if the location contains a fragment.
#
# /path#comment_15 -> will highlight parent of <a name="comment_15">
#

$ ->
  hash = document.location.hash
  $("a[name=" + hash.substr(1) + "]").parent().effect "highlight", {}, 3000  if hash
