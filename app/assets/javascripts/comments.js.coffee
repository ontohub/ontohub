
$(".comments").remoteCollection
  collectionTag: "ol"
  elementTag: "li"
  success: (form) ->
    form.html "Thanks for your comment."
