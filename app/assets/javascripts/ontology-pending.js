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

  if($('aside .info .pending').length > 0) {
    setInterval(updateStatus, 5000);
  }

  $('aside .info .error .help').tipsy({gravity:'s'});
});
