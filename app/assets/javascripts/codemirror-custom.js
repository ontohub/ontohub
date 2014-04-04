// TODO Dynamic loading (requirejs? + mime_type to codemirror helper)
//= require codemirror/modes/haskell
//= require codemirror/modes/sparql
//= require codemirror/modes/xml

$(function() {
  if($("#code-area").length > 0) {
   	editor = CodeMirror.fromTextArea(document.getElementById("code-area"), {
      mode: $("#code-area").data("mime-type"),
      lineNumbers: true,
      readOnly: true
    });

    original_editor_content = editor.getValue();

    btn_edit         = $("#codemirror-btn-edit");
    btn_commit       = $("#codemirror-btn-commit");
    btn_discard      = $("#codemirror-btn-discard");
    form             = $('.edit-form');
    alert_error      = $('.alert-error');
    message_group    = $('#message-group');
    message_textarea = $('#message')[0];

    hasErrorClass    = 'has-error';
    editingClass     = "editing";

    editorPreventFocus();
    btn_edit.unbind('click').click(enableEditing);
  }
});

editorPreventFocus = function(e) {
  editor.setOption("cursorHeight", 0);
};

editorAllowFocus = function(e) {
  editor.setOption("cursorHeight", 1);
};

editorSetFocus = function(e) {
  $(e.getTextArea()).next().addClass(editingClass);
};

editorSetBlur = function(e) {
  $(e.getTextArea()).next().removeClass(editingClass);
};

editorSubmit = function(e) {
  $("form.edit-form").submit();
  return false;
};

editorDiscard = function(e) {
  if(editor.doc.isClean() || confirmDiscard()) {
    discard();
  }
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

confirmDiscard = function() {
  return true; // TODO: Use modal.
};

discard = function() {
  message_textarea.value = ""
  editor.setOption("readOnly", true);
  editor.setValue(original_editor_content);
  message_group.removeClass(hasErrorClass);
  alert_error.hide();
  $('.show-when-editing').hide();
  $('.hide-when-editing').show();

  editorPreventFocus();
  editor.off("focus", editorSetFocus);
  editor.off("blur", editorSetBlur);
};

enableEditing = function(e) {
  e.preventDefault();

  editorAllowFocus();
  editor.on("focus", editorSetFocus);
  editor.on("blur", editorSetBlur);

  editor.setOption("readOnly", false);
  $('.show-when-editing').show();
  $('.hide-when-editing').hide();
  editor.focus();

  btn_commit.unbind('click').click(editorSubmit);
  btn_discard.unbind('click').click(editorDiscard);
  form.unbind('submit').submit(requireCommitMessage);

  return false;
};
