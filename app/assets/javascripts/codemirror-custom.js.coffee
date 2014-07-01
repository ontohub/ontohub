# TODO Dynamic loading (requirejs? + mime_type to codemirror helper)
#= require codemirror/modes/haskell
#= require codemirror/modes/sparql
#= require codemirror/modes/xml
$ ->
  if $("#code-area").length > 0
    editor = CodeMirror.fromTextArea(document.getElementById("code-area"),
      mode: $("#code-area").data("mime-type")
      lineNumbers: true
      readOnly: true
    )

    btn_edit = $("#codemirror-btn-edit")
    btn_commit = $("#codemirror-btn-commit")
    btn_discard = $("#codemirror-btn-discard")
    btn_discard_cancel = $('#coremirror-btn-discard-cancel')
    btn_discard_confirm = $('#codemirror-btn-discard-confirm')
    form = $(".edit-form")
    alert_error = $(".alert-error")
    message_group = $("#message-group")
    message_textarea = $("#message")[0]
    hasErrorClass = "has-error"
    editingClass = "editing"
    discard_modal = $('#discard_modal')

    editorPreventFocus = (e) ->
      editor.setOption "cursorHeight", 0
      return

    editorAllowFocus = (e) ->
      editor.setOption "cursorHeight", 1
      return

    editorSetFocus = (e) ->
      $(e.getTextArea()).next().addClass editingClass
      return

    editorSetBlur = (e) ->
      $(e.getTextArea()).next().removeClass editingClass
      return

    editorSubmit = (e) ->
      $("form.edit-form").submit()
      false

    # Once you discarded an actual change, the first disjunct is false
    # even though the editor content is the original one.
    editorDocClean = ->
      editor.doc.isClean() || original_editor_content == editor.getValue()

    requireCommitMessage = (e) ->
      if $.trim($("#message").val()) is ""
        alert_error.show()
        message_group.addClass hasErrorClass
        false
      else
        true

    discard = (use_modal) ->
      if use_modal
        discard_modal.modal('show')
      else
        message_textarea.value = ""
        editor.setOption "readOnly", true
        editor.setValue original_editor_content
        message_group.removeClass hasErrorClass
        alert_error.hide()
        $(".show-when-editing").hide()
        $(".hide-when-editing").show()
        editorPreventFocus()
        editor.off "focus", editorSetFocus
        editor.off "blur", editorSetBlur
        discard_modal.modal('hide')
      return

    enableEditing = (e) ->
      e.preventDefault()
      editorAllowFocus()
      editor.on "focus", editorSetFocus
      editor.on "blur", editorSetBlur
      editor.setOption "readOnly", false
      $(".show-when-editing").show()
      $(".hide-when-editing").hide()
      editor.focus()
      btn_commit.unbind("click").click editorSubmit
      btn_discard.unbind("click").click(-> discard(!editorDocClean()))
      btn_discard_confirm.unbind('click').click(-> discard(false))
      form.unbind("submit").submit requireCommitMessage
      false

    original_editor_content = editor.getValue()

    discard_modal.modal({show: false})

    editorPreventFocus()
    btn_edit.unbind("click").click enableEditing

  return
