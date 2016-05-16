$("iframe#jobs").load ->
  this.style.height = this.contentWindow.document.body.scrollHeight + 'px'
