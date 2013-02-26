
$(".comments").remoteCollection
  collectionTag: "ol"
  elementTag: "li"
  success: (form) ->
    form.text "Thanks for your comment."
