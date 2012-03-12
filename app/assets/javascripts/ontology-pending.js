$(function() {
  var updateStatus = function() {
    $.getJSON(
      document.location.pathname + '.json',
      function(data) {
        if(data.state != 'pending') {
          location.reload();
        }
      }
    )
  };

  if($('.metadata .info .pending').length > 0) {
    setInterval(updateStatus, 5000);
  }
});
