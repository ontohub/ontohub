// TODO Dynamic loading (requirejs? + mime_type to codemirror helper)
//= require codemirror/modes/haskell
//= require codemirror/modes/sparql
//= require codemirror/modes/xml

$(function() {
    // Setup codemirror highlighting
	if($("#code-area").length > 0) {
	   	editor = CodeMirror.fromTextArea(document.getElementById("code-area"), {
	      mode: $("#code-area").data("mime-type"),
	      lineNumbers: true,
	      readOnly: true
	    });
	}
});