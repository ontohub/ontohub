
$(".metadatable").remoteCollection
  collectionTag: "table tbody"
  elementTag: "tr"
  success: (form) ->
    # clear form and focus the first input
    form.find("fieldset.inputs input").val("").first().focus()
