$(function() {
  var lastStatus = 'pending';

  if($('aside .info .downloading').length > 0) {
    lastStatus = 'downloading';
  }

  if($('aside .info .processing').length > 0) {
    lastStatus = 'processing';
  }

  var updateStatus = function() {
    $.getJSON(
      document.location.pathname + '.json',
      function(data) {
        if(lastStatus != data.state) {
          location.reload();
        }
      }
    );
  };

  if($('aside .info').find('.pending, .downloading, .processing').length > 0) {
    setInterval(updateStatus, 5000);
  }

});
