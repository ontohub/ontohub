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

    // Setup editing functionality
    $("#codemirror-btn-edit").editFile();
  }
});


$.fn.editFile = function() {
  $(this).unbind('click').click(function(e) {
    btn_edit = $("#codemirror-btn-edit");
    btn_update = $("#codemirror-btn-update");
    btn_cancel = $("#codemirror-btn-cancel");
    btn_reset = $("#codemirror-btn-reset");

    btn_edit_previous_html = this.innerHTML;

    // Setup buttons and show edit form
    e.preventDefault();
    $(this).html($(this).data("replace"));
    editor.setOption("readOnly", false);
    $('.show-when-editing').show();
    $('.hide-when-editing').hide();

    // Submit form by clicking on update button
    btn_update.unbind('click').click(function() {
      $("form.edit-form").submit();
      return false;
    });

    // Cancel Button
    btn_cancel.unbind('click').click(function() {
      editor.setOption("readOnly", true);
      $('.show-when-editing').hide();
      $('.hide-when-editing').show();
      return false;
    });

    // Reset Button (rollback)
    btn_reset.unbind('click').click(function() {
      editor.setOption("readOnly", false);
      editor.setValue(original_editor_content);
      return false;
    });

    // Commit message required
    $('.edit-form').unbind('submit').submit(function() {
      if($.trim($('#message').val()) == '') {
        $('.alert-error').show();
        $('#message-group').addClass('has-error')
        return false;
      } else {
        return true;
      }
    });

    return false;

  });
  return this;
};
