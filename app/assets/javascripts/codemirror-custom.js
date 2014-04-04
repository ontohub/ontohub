// TODO Dynamic loading (requirejs? + mime_type to codemirror helper)
//= require codemirror/modes/haskell
//= require codemirror/modes/sparql
//= require codemirror/modes/xml

$(function() {
  if($("#code-area").length > 0) {
    // Setup codemirror highlighting
   	editor = CodeMirror.fromTextArea(document.getElementById("code-area"), {
      mode: $("#code-area").data("mime-type"),
      lineNumbers: true,
      readOnly: true
    });

    original_editor_content = editor.getValue();

    btn_edit      = $("#codemirror-btn-edit");
    btn_commit    = $("#codemirror-btn-commit");
    btn_discard   = $("#codemirror-btn-discard");
    form          = $('.edit-form');
    alert_error   = $('.alert-error');
    message_group = $('#message-group');

    hasErrorClass = 'has-error';
    editingClass  = "editing";

    btn_edit.unbind('click').click(enableEditing);
  }
});

editorSetFocus = function(e) {
  $(e.getTextArea()).next().addClass(editingClass);
};

editorSetBlur = function(e) {
  $(e.getTextArea()).next().removeClass(editingClass);
};

editorSetupSubmit = function(e) {
  $("form.edit-form").submit();
  return false;
};

editorSetupDiscard = function(e) {
  $('#message')[0].value = ""
  editor.setOption("readOnly", true);
  editor.setValue(original_editor_content);
  message_group.removeClass(hasErrorClass);
  alert_error.hide();
  $('.show-when-editing').hide();
  $('.hide-when-editing').show();

  editor.off("focus", editorSetFocus);
  editor.off("blur", editorSetBlur);
  return false;
};

requireCommitMessage = function(e) {
  if($.trim($('#message').val()) == '') {
    alert_error.show();
    message_group.addClass(hasErrorClass)
    return false;
  } else {
    return true;
  }
};

enableEditing = function(e) {
  e.preventDefault();

  editor.on("focus", editorSetFocus);
  editor.on("blur", editorSetBlur);

  editor.setOption("readOnly", false);
  $('.show-when-editing').show();
  $('.hide-when-editing').hide();
  editor.focus();

  btn_commit.unbind('click').click(editorSetupSubmit);
  btn_discard.unbind('click').click(editorSetupDiscard);
  form.unbind('submit').submit(requireCommitMessage);

  return false;
};
